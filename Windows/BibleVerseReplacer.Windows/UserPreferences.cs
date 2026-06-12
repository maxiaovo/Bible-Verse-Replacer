using Microsoft.Win32;

namespace BibleVerseReplacer.Windows
{
    internal enum OutputFormat
    {
        ReferenceVerseLines = 0,
        ContinuousText = 1,
        ReferenceHeader = 2,
        NumberedVerses = 3
    }

    internal sealed class UserPreferences
    {
        public static readonly UserPreferences Instance = new UserPreferences();

        private const string RegistryPath = @"Software\BibleVerseReplacer";
        private const string ShortcutName = "Shortcut";
        private const string OutputFormatName = "OutputFormat";

        private UserPreferences()
        {
        }

        public KeyboardShortcut Shortcut
        {
            get
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath))
                {
                    return KeyboardShortcut.FromStorageString(key == null ? null : key.GetValue(ShortcutName) as string);
                }
            }
            set
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(RegistryPath))
                {
                    key.SetValue(ShortcutName, value.ToStorageString());
                }
            }
        }

        public OutputFormat OutputFormat
        {
            get
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath))
                {
                    object raw = key == null ? null : key.GetValue(OutputFormatName);
                    int value;
                    if (raw == null || !int.TryParse(raw.ToString(), out value))
                    {
                        return OutputFormat.ReferenceVerseLines;
                    }
                    return (OutputFormat)value;
                }
            }
            set
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(RegistryPath))
                {
                    key.SetValue(OutputFormatName, (int)value);
                }
            }
        }
    }
}

