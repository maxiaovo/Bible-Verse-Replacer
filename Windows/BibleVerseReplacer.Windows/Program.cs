using System;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal static class Program
    {
        [STAThread]
        private static void Main(string[] args)
        {
            if (args.Length == 1 && args[0] == "--self-test")
            {
                Environment.Exit(SelfTest.Run());
                return;
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            try
            {
                BibleStore.Instance.Load();
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "经文库加载失败：\n\n" + ex.Message,
                    "Bible Verse Replacer",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            Application.Run(new TrayAppContext());
        }
    }
}

