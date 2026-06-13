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

    internal enum ReferenceLabelMode
    {
        NormalizedFull = 0,
        PreserveInput = 1,
        Omit = 2
    }

    internal enum CombinedPassageMode
    {
        CompactEllipsis = 0,
        GroupedLines = 1
    }

    internal sealed class UserPreferences
    {
        public static readonly UserPreferences Instance = new UserPreferences();

        private const string RegistryPath = @"Software\BibleVerseReplacer";
        private const string ShortcutName = "Shortcut";
        private const string OutputFormatName = "OutputFormat";
        private const string ReferenceLabelModeName = "ReferenceLabelMode";
        private const string CombinedPassageModeName = "CombinedPassageMode";
        private const string AutoCheckUpdatesName = "AutoCheckUpdates";

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

        public ReferenceLabelMode ReferenceLabelMode
        {
            get
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath))
                {
                    object raw = key == null ? null : key.GetValue(ReferenceLabelModeName);
                    int value;
                    if (raw == null || !int.TryParse(raw.ToString(), out value))
                    {
                        return ReferenceLabelMode.NormalizedFull;
                    }
                    return (ReferenceLabelMode)value;
                }
            }
            set
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(RegistryPath))
                {
                    key.SetValue(ReferenceLabelModeName, (int)value);
                }
            }
        }

        public CombinedPassageMode CombinedPassageMode
        {
            get
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath))
                {
                    object raw = key == null ? null : key.GetValue(CombinedPassageModeName);
                    int value;
                    if (raw == null || !int.TryParse(raw.ToString(), out value))
                    {
                        return CombinedPassageMode.CompactEllipsis;
                    }
                    return value == (int)CombinedPassageMode.GroupedLines
                        ? CombinedPassageMode.GroupedLines
                        : CombinedPassageMode.CompactEllipsis;
                }
            }
            set
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(RegistryPath))
                {
                    key.SetValue(CombinedPassageModeName, (int)value);
                }
            }
        }

        public bool AutoCheckUpdates
        {
            get
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath))
                {
                    object raw = key == null ? null : key.GetValue(AutoCheckUpdatesName);
                    int value;
                    if (raw == null || !int.TryParse(raw.ToString(), out value))
                    {
                        return true;
                    }
                    return value != 0;
                }
            }
            set
            {
                using (RegistryKey key = Registry.CurrentUser.CreateSubKey(RegistryPath))
                {
                    key.SetValue(AutoCheckUpdatesName, value ? 1 : 0);
                }
            }
        }
    }
}
