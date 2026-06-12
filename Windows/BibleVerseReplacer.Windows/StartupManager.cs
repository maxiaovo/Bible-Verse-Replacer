using System;
using System.Reflection;
using Microsoft.Win32;

namespace BibleVerseReplacer.Windows
{
    internal static class StartupManager
    {
        private const string RunPath = @"Software\Microsoft\Windows\CurrentVersion\Run";
        private const string AppName = "BibleVerseReplacer";

        public static bool IsEnabled
        {
            get
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RunPath))
                {
                    return key != null && key.GetValue(AppName) != null;
                }
            }
        }

        public static void SetEnabled(bool enabled)
        {
            using (RegistryKey key = Registry.CurrentUser.CreateSubKey(RunPath))
            {
                if (enabled)
                {
                    key.SetValue(AppName, "\"" + Assembly.GetExecutingAssembly().Location + "\"");
                }
                else
                {
                    key.DeleteValue(AppName, false);
                }
            }
        }
    }
}

