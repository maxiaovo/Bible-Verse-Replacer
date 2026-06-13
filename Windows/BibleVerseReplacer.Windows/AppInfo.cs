using System;
using System.Reflection;

namespace BibleVerseReplacer.Windows
{
    internal static class AppInfo
    {
        public const string RepositoryUrl = "https://github.com/maxiaovo/Bible-Verse-Replacer";

        public static string Version
        {
            get
            {
                System.Version version = Assembly.GetExecutingAssembly().GetName().Version;
                return version.Major + "." + version.Minor + "." + version.Build;
            }
        }

        public static string VersionDisplay
        {
            get { return "v" + Version; }
        }
    }
}
