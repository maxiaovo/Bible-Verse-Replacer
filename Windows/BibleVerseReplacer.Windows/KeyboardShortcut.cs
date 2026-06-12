using System;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    [Flags]
    internal enum HotKeyModifiers : uint
    {
        None = 0,
        Alt = 0x0001,
        Control = 0x0002,
        Shift = 0x0004,
        Win = 0x0008
    }

    internal sealed class KeyboardShortcut
    {
        public KeyboardShortcut(Keys key, HotKeyModifiers modifiers)
        {
            Key = key;
            Modifiers = modifiers;
        }

        public Keys Key { get; private set; }
        public HotKeyModifiers Modifiers { get; private set; }

        public static KeyboardShortcut Default
        {
            get { return new KeyboardShortcut(Keys.B, HotKeyModifiers.Control | HotKeyModifiers.Alt | HotKeyModifiers.Win); }
        }

        public string DisplayText
        {
            get
            {
                string text = string.Empty;
                if ((Modifiers & HotKeyModifiers.Control) != 0)
                {
                    text += "Ctrl + ";
                }
                if ((Modifiers & HotKeyModifiers.Alt) != 0)
                {
                    text += "Alt + ";
                }
                if ((Modifiers & HotKeyModifiers.Shift) != 0)
                {
                    text += "Shift + ";
                }
                if ((Modifiers & HotKeyModifiers.Win) != 0)
                {
                    text += "Win + ";
                }
                return text + Key;
            }
        }

        public string ToStorageString()
        {
            return ((uint)Modifiers) + "|" + (int)Key;
        }

        public static KeyboardShortcut FromStorageString(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return Default;
            }

            string[] parts = value.Split('|');
            uint modifiers;
            int key;
            if (parts.Length != 2 || !uint.TryParse(parts[0], out modifiers) || !int.TryParse(parts[1], out key))
            {
                return Default;
            }

            return new KeyboardShortcut((Keys)key, (HotKeyModifiers)modifiers);
        }

        public static KeyboardShortcut FromKeyEvent(KeyEventArgs e)
        {
            HotKeyModifiers modifiers = HotKeyModifiers.None;
            if (e.Control)
            {
                modifiers |= HotKeyModifiers.Control;
            }
            if (e.Alt)
            {
                modifiers |= HotKeyModifiers.Alt;
            }
            if (e.Shift)
            {
                modifiers |= HotKeyModifiers.Shift;
            }

            if ((GetKeyState((int)Keys.LWin) < 0) || (GetKeyState((int)Keys.RWin) < 0))
            {
                modifiers |= HotKeyModifiers.Win;
            }

            Keys key = e.KeyCode;
            if (key == Keys.ControlKey || key == Keys.Menu || key == Keys.ShiftKey || key == Keys.LWin || key == Keys.RWin)
            {
                return null;
            }

            if (modifiers == HotKeyModifiers.None)
            {
                return null;
            }

            return new KeyboardShortcut(key, modifiers);
        }

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        private static extern short GetKeyState(int nVirtKey);
    }
}

