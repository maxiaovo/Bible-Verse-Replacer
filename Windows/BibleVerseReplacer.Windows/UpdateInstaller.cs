using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class UpdateInstaller
    {
        private readonly string downloadUrl;
        private readonly string latestVersion;
        private readonly Action exitApplication;
        private readonly Form progressForm = new Form();
        private readonly ProgressBar progressBar = new ProgressBar();
        private readonly Label statusLabel = new Label();
        private string tempDirectory;
        private string zipPath;

        public UpdateInstaller(string downloadUrl, string latestVersion, Action exitApplication)
        {
            this.downloadUrl = downloadUrl;
            this.latestVersion = latestVersion;
            this.exitApplication = exitApplication;
        }

        public void Start(IWin32Window owner)
        {
            tempDirectory = Path.Combine(Path.GetTempPath(), "BibleVerseReplacerUpdate-" + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(tempDirectory);
            zipPath = Path.Combine(tempDirectory, "update.zip");

            BuildProgressForm();
            progressForm.Show(owner);

            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;
            WebClient client = new WebClient();
            client.Headers.Add("User-Agent", "BibleVerseReplacer");
            client.DownloadProgressChanged += delegate(object sender, DownloadProgressChangedEventArgs e)
            {
                progressBar.Value = Math.Min(80, Math.Max(0, (int)(e.ProgressPercentage * 0.8)));
                statusLabel.Text = "正在下载... " + e.ProgressPercentage + "%";
            };
            client.DownloadFileCompleted += delegate(object sender, System.ComponentModel.AsyncCompletedEventArgs e)
            {
                client.Dispose();
                if (e.Error != null)
                {
                    ShowError(e.Error);
                    return;
                }

                if (e.Cancelled)
                {
                    ShowError(new InvalidOperationException("下载已取消。"));
                    return;
                }

                PrepareInstallAsync();
            };
            client.DownloadFileAsync(new Uri(downloadUrl), zipPath);
        }

        private void BuildProgressForm()
        {
            progressForm.Text = "正在更新";
            progressForm.Icon = AppIcons.Current;
            progressForm.StartPosition = FormStartPosition.CenterScreen;
            progressForm.FormBorderStyle = FormBorderStyle.FixedDialog;
            progressForm.MinimizeBox = false;
            progressForm.MaximizeBox = false;
            progressForm.ClientSize = new System.Drawing.Size(420, 130);

            Label title = new Label();
            title.Text = "下载 v" + latestVersion;
            title.AutoSize = true;
            title.Font = new System.Drawing.Font(progressForm.Font.FontFamily, 11, System.Drawing.FontStyle.Bold);
            title.Location = new System.Drawing.Point(22, 20);
            progressForm.Controls.Add(title);

            statusLabel.Text = "正在连接 GitHub Releases...";
            statusLabel.AutoSize = true;
            statusLabel.ForeColor = System.Drawing.SystemColors.GrayText;
            statusLabel.Location = new System.Drawing.Point(24, 54);
            progressForm.Controls.Add(statusLabel);

            progressBar.Location = new System.Drawing.Point(24, 84);
            progressBar.Width = 370;
            progressBar.Minimum = 0;
            progressBar.Maximum = 100;
            progressForm.Controls.Add(progressBar);
        }

        private void PrepareInstallAsync()
        {
            statusLabel.Text = "正在解压安装包...";
            progressBar.Value = 85;

            Task.Factory.StartNew(delegate
            {
                string extractDirectory = Path.Combine(tempDirectory, "extracted");
                Directory.CreateDirectory(extractDirectory);
                ZipFile.ExtractToDirectory(zipPath, extractDirectory);

                string sourceDirectory = FindPackageDirectory(extractDirectory);
                if (sourceDirectory == null)
                {
                    throw new InvalidOperationException("安装包中没有找到 BibleVerseReplacer.exe。");
                }

                string installDirectory = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar);
                string batchPath = WriteInstallerBatch(sourceDirectory, installDirectory, tempDirectory);
                LaunchInstallerBatch(batchPath, installDirectory);
            }).ContinueWith(task =>
            {
                if (task.IsFaulted)
                {
                    ShowError(task.Exception.GetBaseException());
                    return;
                }

                statusLabel.Text = "正在重启程序...";
                progressBar.Value = 100;
                progressForm.Close();
                exitApplication();
            }, TaskScheduler.FromCurrentSynchronizationContext());
        }

        private static string FindPackageDirectory(string extractDirectory)
        {
            string direct = Path.Combine(extractDirectory, "BibleVerseReplacer");
            if (File.Exists(Path.Combine(direct, "BibleVerseReplacer.exe")))
            {
                return direct;
            }

            foreach (string exe in Directory.GetFiles(extractDirectory, "BibleVerseReplacer.exe", SearchOption.AllDirectories))
            {
                return Path.GetDirectoryName(exe);
            }

            return null;
        }

        private static string WriteInstallerBatch(string sourceDirectory, string installDirectory, string tempDirectory)
        {
            string batchPath = Path.Combine(tempDirectory, "install-update.bat");
            string exePath = Path.Combine(installDirectory, "BibleVerseReplacer.exe");
            string script =
                "@echo off\r\n" +
                "setlocal\r\n" +
                "set \"SRC=" + sourceDirectory + "\"\r\n" +
                "set \"DST=" + installDirectory + "\"\r\n" +
                "set \"EXE=" + exePath + "\"\r\n" +
                "set \"TEMP_DIR=" + tempDirectory + "\"\r\n" +
                "ping 127.0.0.1 -n 2 > nul\r\n" +
                ":wait\r\n" +
                "tasklist /FI \"IMAGENAME eq BibleVerseReplacer.exe\" | find /I \"BibleVerseReplacer.exe\" > nul\r\n" +
                "if not errorlevel 1 (\r\n" +
                "  timeout /t 1 /nobreak > nul\r\n" +
                "  goto wait\r\n" +
                ")\r\n" +
                "xcopy \"%SRC%\\*\" \"%DST%\\\" /E /Y /I > nul\r\n" +
                "start \"\" \"%EXE%\"\r\n" +
                "rmdir /S /Q \"%TEMP_DIR%\"\r\n" +
                "del \"%~f0\"\r\n";
            File.WriteAllText(batchPath, script, System.Text.Encoding.ASCII);
            return batchPath;
        }

        private static void LaunchInstallerBatch(string batchPath, string installDirectory)
        {
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = batchPath;
            startInfo.UseShellExecute = true;
            startInfo.WindowStyle = ProcessWindowStyle.Hidden;

            if (!IsDirectoryWritable(installDirectory))
            {
                startInfo.Verb = "runas";
            }

            Process.Start(startInfo);
        }

        private static bool IsDirectoryWritable(string directory)
        {
            try
            {
                string testPath = Path.Combine(directory, ".update-write-test-" + Guid.NewGuid().ToString("N"));
                File.WriteAllText(testPath, "test");
                File.Delete(testPath);
                return true;
            }
            catch
            {
                return false;
            }
        }

        private void ShowError(Exception error)
        {
            progressForm.Close();
            Cleanup();
            MessageBox.Show(
                "自动更新失败：\n\n" + error.Message + "\n\n可以先手动打开 Release 页面下载最新版。",
                "Bible Verse Replacer",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
        }

        private void Cleanup()
        {
            try
            {
                if (!string.IsNullOrEmpty(tempDirectory) && Directory.Exists(tempDirectory))
                {
                    Directory.Delete(tempDirectory, true);
                }
            }
            catch
            {
            }
        }
    }
}
