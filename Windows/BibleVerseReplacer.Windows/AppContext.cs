using System;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class TrayAppContext : ApplicationContext
    {
        private readonly NotifyIcon notifyIcon;
        private readonly GlobalHotKey hotKey = new GlobalHotKey();
        private readonly ReplacementCoordinator replacementCoordinator;
        private SettingsForm settingsForm;

        public TrayAppContext()
        {
            notifyIcon = new NotifyIcon();
            notifyIcon.Icon = AppIcons.Current;
            notifyIcon.Text = "Bible Verse Replacer";
            notifyIcon.Visible = true;

            replacementCoordinator = new ReplacementCoordinator(notifyIcon);
            notifyIcon.ContextMenuStrip = BuildMenu();
            notifyIcon.DoubleClick += delegate { ShowSettings(); };

            RegisterHotKey();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                hotKey.Dispose();
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
            menu.Items.Add(new ToolStripSeparator());
            menu.Items.Add("设置...", null, delegate { ShowSettings(); });
            menu.Items.Add("经文库：" + BibleStore.Instance.SourceSummary).Enabled = false;
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
    }
}
