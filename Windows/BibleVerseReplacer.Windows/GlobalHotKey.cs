using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class GlobalHotKey : NativeWindow, IDisposable
    {
        private const int WmHotKey = 0x0312;
        private readonly int id = 0xB812;
        private Action pressed;
        private bool registered;

        public GlobalHotKey()
        {
            CreateHandle(new CreateParams());
        }

        public void Register(KeyboardShortcut shortcut, Action onPressed)
        {
            Unregister();
            pressed = onPressed;
            registered = RegisterHotKey(Handle, id, (uint)shortcut.Modifiers, (uint)shortcut.Key);
            if (!registered)
            {
                throw new InvalidOperationException("快捷键注册失败，可能与其他应用冲突。");
            }
        }

        public void Unregister()
        {
            if (registered)
            {
                UnregisterHotKey(Handle, id);
                registered = false;
            }
        }

        protected override void WndProc(ref Message m)
        {
            if (m.Msg == WmHotKey)
            {
                if (pressed != null)
                {
                    pressed();
                }
                return;
            }
            base.WndProc(ref m);
        }

        public void Dispose()
        {
            Unregister();
            DestroyHandle();
        }

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool UnregisterHotKey(IntPtr hWnd, int id);
    }
}

