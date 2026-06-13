using System;
using System.Diagnostics;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class TrayAppContext : ApplicationContext
    {
        private readonly NotifyIcon notifyIcon;
        private readonly Control uiInvoker = new Control();
        private readonly GlobalHotKey hotKey = new GlobalHotKey();
        private readonly ReplacementCoordinator replacementCoordinator;
        private readonly UpdateChecker updateChecker = new UpdateChecker();
        private readonly Timer startupUpdateTimer = new Timer();
        private SettingsForm settingsForm;
        private UpdateInstaller updateInstaller;
        private bool checkingUpdates;

        public TrayAppContext()
        {
            uiInvoker.CreateControl();

            notifyIcon = new NotifyIcon();
            notifyIcon.Icon = AppIcons.Current;
            notifyIcon.Text = "Bible Verse Replacer";
            notifyIcon.Visible = true;

            replacementCoordinator = new ReplacementCoordinator(notifyIcon);
            notifyIcon.ContextMenuStrip = BuildMenu();
            notifyIcon.DoubleClick += delegate { ShowSettings(); };

            RegisterHotKey();
            ScheduleAutomaticUpdateCheckIfNeeded();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                hotKey.Dispose();
                startupUpdateTimer.Dispose();
                uiInvoker.Dispose();
                notifyIcon.Visible = false;
                notifyIcon.Dispose();
                if (settingsForm != null)
                {
                    settingsForm.Dispose();
                }
            }
            base.Dispose(disposing);
        }

        private ContextMenuStrip BuildMenu()
        {
            ContextMenuStrip menu = new ContextMenuStrip();
            menu.Items.Add("替换所选经文", null, delegate { replacementCoordinator.ReplaceSelection(); });
            menu.Items.Add("当前快捷键：" + UserPreferences.Instance.Shortcut.DisplayText).Enabled = false;
            menu.Items.Add("作者：大侠请留步").Enabled = false;
            menu.Items.Add("版本：" + AppInfo.VersionDisplay).Enabled = false;
            menu.Items.Add("仓库：" + AppInfo.RepositoryUrl, null, delegate { Process.Start(AppInfo.RepositoryUrl); });
            menu.Items.Add(new ToolStripSeparator());
            menu.Items.Add("设置...", null, delegate { ShowSettings(); });
            menu.Items.Add("经文库：" + BibleStore.Instance.SourceSummary).Enabled = false;
            menu.Items.Add("检查更新", null, delegate { CheckForUpdates(true); });
            menu.Items.Add(new ToolStripSeparator());
            menu.Items.Add("退出", null, delegate { ExitThread(); });
            return menu;
        }

        public void RegisterHotKey()
        {
            try
            {
                hotKey.Register(UserPreferences.Instance.Shortcut, replacementCoordinator.ReplaceSelection);
                notifyIcon.ContextMenuStrip = BuildMenu();
            }
            catch (Exception ex)
            {
                notifyIcon.BalloonTipTitle = "经文替换";
                notifyIcon.BalloonTipText = ex.Message;
                notifyIcon.ShowBalloonTip(3000);
            }
        }

        private void ShowSettings()
        {
            if (settingsForm == null || settingsForm.IsDisposed)
            {
                settingsForm = new SettingsForm(RegisterHotKey);
            }
            settingsForm.Show();
            settingsForm.WindowState = FormWindowState.Normal;
            settingsForm.Activate();
        }

        private void ScheduleAutomaticUpdateCheckIfNeeded()
        {
            if (!UserPreferences.Instance.AutoCheckUpdates)
            {
                return;
            }

            startupUpdateTimer.Interval = 3000;
            startupUpdateTimer.Tick += delegate
            {
                startupUpdateTimer.Stop();
                CheckForUpdates(false);
            };
            startupUpdateTimer.Start();
        }

        private void CheckForUpdates(bool interactive)
        {
            if (checkingUpdates)
            {
                if (interactive)
                {
                    notifyIcon.BalloonTipTitle = "经文替换";
                    notifyIcon.BalloonTipText = "正在检查更新...";
                    notifyIcon.ShowBalloonTip(2000);
                }
                return;
            }

            checkingUpdates = true;
            updateChecker.CheckAsync(result =>
            {
                if (uiInvoker.IsDisposed)
                {
                    return;
                }

                uiInvoker.BeginInvoke((Action)(() =>
                {
                    checkingUpdates = false;
                    HandleUpdateCheckResult(result, interactive);
                }));
            });
        }

        private void HandleUpdateCheckResult(UpdateCheckResult result, bool interactive)
        {
            if (result.Error != null)
            {
                if (interactive)
                {
                    MessageBox.Show(
                        "检查更新失败：\n\n" + result.Error.Message,
                        "Bible Verse Replacer",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                }
                return;
            }

            if (result.IsUpdateAvailable)
            {
                if (string.IsNullOrEmpty(result.InstallerAssetUrl))
                {
                    DialogResult openRelease = MessageBox.Show(
                        "发现新版本 v" + result.LatestVersion + "\n当前版本：v" + result.CurrentVersion + "\n\n没有找到可自动安装的 Windows 安装包，是否打开下载页面？",
                        "Bible Verse Replacer",
                        MessageBoxButtons.YesNo,
                        MessageBoxIcon.Information);
                    if (openRelease == DialogResult.Yes)
                    {
                        Process.Start(result.ReleaseUrl);
                    }
                    return;
                }

                DialogResult answer = MessageBox.Show(
                    "发现新版本 v" + result.LatestVersion + "\n当前版本：v" + result.CurrentVersion + "\n\n是否下载并自动安装？安装完成后会自动重启程序。",
                    "Bible Verse Replacer",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Information);
                if (answer == DialogResult.Yes)
                {
                    updateInstaller = new UpdateInstaller(
                        result.InstallerAssetUrl,
                        result.LatestVersion,
                        delegate { ExitThread(); });
                    updateInstaller.Start(null);
                }
                return;
            }

            if (interactive)
            {
                MessageBox.Show(
                    "当前已是最新版本：v" + result.CurrentVersion,
                    "Bible Verse Replacer",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
        }
    }
}
