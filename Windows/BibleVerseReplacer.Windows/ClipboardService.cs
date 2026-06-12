using System;
using System.Threading;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class ClipboardService
    {
        public IDataObject Snapshot()
        {
            return Clipboard.GetDataObject();
        }

        public void Restore(IDataObject snapshot)
        {
            if (snapshot != null)
            {
                Clipboard.SetDataObject(snapshot, true);
            }
        }

        public string CopySelectedText()
        {
            int attempts = 0;
            string before = Clipboard.ContainsText() ? Clipboard.GetText() : null;
            SendKeys.SendWait("^c");

            while (attempts < 30)
            {
                Application.DoEvents();
                Thread.Sleep(20);
                if (Clipboard.ContainsText())
                {
                    string current = Clipboard.GetText();
                    if (current != before || !string.IsNullOrWhiteSpace(current))
                    {
                        return current;
                    }
                }
                attempts++;
            }

            return Clipboard.ContainsText() ? Clipboard.GetText() : null;
        }

        public void Paste(string text)
        {
            Clipboard.SetText(text ?? string.Empty);
            SendKeys.SendWait("^v");
        }
    }
}

