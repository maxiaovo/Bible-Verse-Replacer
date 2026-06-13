using System;
using System.Drawing;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal static class AppIcons
    {
        private static readonly Lazy<Icon> CurrentIcon = new Lazy<Icon>(LoadIcon);

        public static Icon Current
        {
            get { return CurrentIcon.Value; }
        }

        private static Icon LoadIcon()
        {
            try
            {
                Icon icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
                if (icon != null)
                {
                    return icon;
                }
            }
            catch
            {
            }

            return SystemIcons.Application;
        }
    }
}
