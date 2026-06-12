using System;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class ReplacementCoordinator
    {
        private readonly ClipboardService clipboard = new ClipboardService();
        private readonly ReferenceParser parser = new ReferenceParser();
        private readonly VerseFormatter formatter = new VerseFormatter();
        private readonly NotifyIcon notifyIcon;

        public ReplacementCoordinator(NotifyIcon notifyIcon)
        {
            this.notifyIcon = notifyIcon;
        }

        public void ReplaceSelection()
        {
            IDataObject snapshot = clipboard.Snapshot();

            try
            {
                string selectedText = clipboard.CopySelectedText();
                if (string.IsNullOrWhiteSpace(selectedText))
                {
                    clipboard.Restore(snapshot);
                    Notify("没有选中文字");
                    return;
                }

                VerseReference reference = parser.Parse(selectedText);
                string replacement = formatter.Format(
                    reference,
                    BibleStore.Instance.VersesFor(reference),
                    UserPreferences.Instance.OutputFormat);

                clipboard.Paste(replacement);
                Timer restoreTimer = new Timer();
                restoreTimer.Interval = 350;
                restoreTimer.Tick += delegate
                {
                    restoreTimer.Stop();
                    restoreTimer.Dispose();
                    clipboard.Restore(snapshot);
                };
                restoreTimer.Start();
            }
            catch (Exception ex)
            {
                clipboard.Restore(snapshot);
                Notify(ex.Message);
            }
        }

        private void Notify(string message)
        {
            notifyIcon.BalloonTipTitle = "经文替换";
            notifyIcon.BalloonTipText = message;
            notifyIcon.ShowBalloonTip(2500);
        }
    }
}

