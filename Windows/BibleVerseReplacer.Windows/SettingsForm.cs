using System;
using System.Drawing;
using System.Windows.Forms;

namespace BibleVerseReplacer.Windows
{
    internal sealed class SettingsForm : Form
    {
        private readonly Action onPreferencesChanged;
        private readonly TextBox shortcutTextBox = new TextBox();
        private readonly ComboBox outputFormatComboBox = new ComboBox();
        private readonly ComboBox referenceLabelComboBox = new ComboBox();
        private readonly ComboBox combinedPassageComboBox = new ComboBox();
        private readonly CheckBox startupCheckBox = new CheckBox();
        private readonly Label dataLabel = new Label();
        private bool recordingShortcut;

        public SettingsForm(Action onPreferencesChanged)
        {
            this.onPreferencesChanged = onPreferencesChanged;
            Text = "Bible Verse Replacer 设置";
            StartPosition = FormStartPosition.CenterScreen;
            Size = new Size(520, 415);
            MinimumSize = new Size(520, 415);
            MaximizeBox = false;
            KeyPreview = true;

            BuildUi();
            LoadValues();
        }

        protected override void OnKeyDown(KeyEventArgs e)
        {
            base.OnKeyDown(e);
            if (!recordingShortcut)
            {
                return;
            }

            if (e.KeyCode == Keys.Escape)
            {
                recordingShortcut = false;
                shortcutTextBox.Text = UserPreferences.Instance.Shortcut.DisplayText;
                return;
            }

            KeyboardShortcut shortcut = KeyboardShortcut.FromKeyEvent(e);
            if (shortcut == null)
            {
                shortcutTextBox.Text = "请包含 Ctrl / Alt / Shift / Win";
                return;
            }

            UserPreferences.Instance.Shortcut = shortcut;
            shortcutTextBox.Text = shortcut.DisplayText;
            recordingShortcut = false;
            onPreferencesChanged();
            e.Handled = true;
        }

        private void BuildUi()
        {
            Label title = new Label();
            title.Text = "经文替换";
            title.Font = new Font(Font.FontFamily, 16, FontStyle.Bold);
            title.AutoSize = true;
            title.Location = new Point(24, 22);
            Controls.Add(title);

            Label subtitle = new Label();
            subtitle.Text = "设置全局快捷键、输出格式和开机启动。";
            subtitle.AutoSize = true;
            subtitle.ForeColor = SystemColors.GrayText;
            subtitle.Location = new Point(26, 56);
            Controls.Add(subtitle);

            AddLabel("快捷键", 30, 96);
            shortcutTextBox.ReadOnly = true;
            shortcutTextBox.Location = new Point(120, 92);
            shortcutTextBox.Width = 220;
            shortcutTextBox.TabStop = false;
            shortcutTextBox.Click += delegate
            {
                recordingShortcut = true;
                shortcutTextBox.Text = "请按新快捷键...";
                shortcutTextBox.Focus();
            };
            Controls.Add(shortcutTextBox);

            Button recordButton = new Button();
            recordButton.Text = "录制";
            recordButton.Location = new Point(352, 90);
            recordButton.Width = 80;
            recordButton.Click += delegate
            {
                recordingShortcut = true;
                shortcutTextBox.Text = "请按新快捷键...";
                shortcutTextBox.Focus();
            };
            Controls.Add(recordButton);

            AddLabel("输出格式", 30, 138);
            outputFormatComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            outputFormatComboBox.Location = new Point(120, 134);
            outputFormatComboBox.Width = 260;
            outputFormatComboBox.Items.Add("书卷 章:节 经文");
            outputFormatComboBox.Items.Add("连续正文");
            outputFormatComboBox.Items.Add("首行引用 + 分节经文");
            outputFormatComboBox.Items.Add("每节带节号");
            outputFormatComboBox.SelectedIndexChanged += delegate
            {
                if (outputFormatComboBox.SelectedIndex >= 0)
                {
                    UserPreferences.Instance.OutputFormat = (OutputFormat)outputFormatComboBox.SelectedIndex;
                }
            };
            Controls.Add(outputFormatComboBox);

            AddLabel("引用标签", 30, 176);
            referenceLabelComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            referenceLabelComboBox.Location = new Point(120, 172);
            referenceLabelComboBox.Width = 260;
            referenceLabelComboBox.Items.Add("改写为完整标签");
            referenceLabelComboBox.Items.Add("保留输入标签");
            referenceLabelComboBox.Items.Add("不保留标签");
            referenceLabelComboBox.SelectedIndexChanged += delegate
            {
                if (referenceLabelComboBox.SelectedIndex >= 0)
                {
                    UserPreferences.Instance.ReferenceLabelMode = (ReferenceLabelMode)referenceLabelComboBox.SelectedIndex;
                }
            };
            Controls.Add(referenceLabelComboBox);

            AddLabel("组合显示", 30, 214);
            combinedPassageComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            combinedPassageComboBox.Location = new Point(120, 210);
            combinedPassageComboBox.Width = 260;
            combinedPassageComboBox.Items.Add("合并为一段（省略号连接）");
            combinedPassageComboBox.Items.Add("按片段分行");
            combinedPassageComboBox.SelectedIndexChanged += delegate
            {
                if (combinedPassageComboBox.SelectedIndex >= 0)
                {
                    UserPreferences.Instance.CombinedPassageMode = (CombinedPassageMode)combinedPassageComboBox.SelectedIndex;
                }
            };
            Controls.Add(combinedPassageComboBox);

            startupCheckBox.Text = "开机自启动";
            startupCheckBox.AutoSize = true;
            startupCheckBox.Location = new Point(120, 252);
            startupCheckBox.CheckedChanged += delegate
            {
                StartupManager.SetEnabled(startupCheckBox.Checked);
            };
            Controls.Add(startupCheckBox);

            AddLabel("经文库", 30, 296);
            dataLabel.AutoSize = true;
            dataLabel.Location = new Point(120, 296);
            Controls.Add(dataLabel);

            Button closeButton = new Button();
            closeButton.Text = "关闭";
            closeButton.Location = new Point(390, 328);
            closeButton.Width = 80;
            closeButton.Click += delegate { Hide(); };
            Controls.Add(closeButton);
        }

        private void LoadValues()
        {
            shortcutTextBox.Text = UserPreferences.Instance.Shortcut.DisplayText;
            outputFormatComboBox.SelectedIndex = (int)UserPreferences.Instance.OutputFormat;
            referenceLabelComboBox.SelectedIndex = (int)UserPreferences.Instance.ReferenceLabelMode;
            combinedPassageComboBox.SelectedIndex = (int)UserPreferences.Instance.CombinedPassageMode;
            startupCheckBox.Checked = StartupManager.IsEnabled;
            dataLabel.Text = BibleStore.Instance.SourceSummary;
        }

        private void AddLabel(string text, int x, int y)
        {
            Label label = new Label();
            label.Text = text;
            label.AutoSize = true;
            label.ForeColor = SystemColors.GrayText;
            label.Location = new Point(x, y);
            Controls.Add(label);
        }
    }
}
