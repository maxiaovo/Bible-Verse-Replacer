using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class ReplacementCoordinator
    {
        private readonly ClipboardService clipboard = new ClipboardService();
        private readonly ReferenceParser parser = new ReferenceParser();
        private readonly VerseFormatter formatter = new VerseFormatter();
        private readonly ArticleReferenceReplacer articleReplacer;
        private readonly NotifyIcon notifyIcon;

        public ReplacementCoordinator(NotifyIcon notifyIcon)
        {
            this.notifyIcon = notifyIcon;
            articleReplacer = new ArticleReferenceReplacer(parser, formatter);
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

                ParsedReference reference = parser.ParseSelection(selectedText);
                List<PassageVerseGroup> verseGroups = BibleStore.Instance.VerseGroupsFor(reference);
                string replacement = formatter.Format(
                    reference,
                    BibleStore.Instance.VersesFor(reference),
                    verseGroups,
                    UserPreferences.Instance.OutputFormat,
                    UserPreferences.Instance.ReferenceLabelMode,
                    selectedText,
                    UserPreferences.Instance.CombinedPassageMode,
                    UserPreferences.Instance.QuotationStyle);

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
                ArticleReplacementResult articleResult = articleReplacer.ReplaceReferences(
                    selectedText,
                    UserPreferences.Instance.OutputFormat,
                    UserPreferences.Instance.ReferenceLabelMode,
                    UserPreferences.Instance.CombinedPassageMode,
                    UserPreferences.Instance.QuotationStyle);
                if (!articleResult.Changed)
                {
                    clipboard.Restore(snapshot);
                    Notify(articleResult.SkippedExisting > 0 ? "已检测到经文正文，无需重复替换" : ex.Message);
                    return;
                }

                clipboard.Paste(articleResult.Text);
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
        }

        private void Notify(string message)
        {
            notifyIcon.BalloonTipTitle = "经文替换";
            notifyIcon.BalloonTipText = message;
            notifyIcon.ShowBalloonTip(2500);
        }
    }
}
