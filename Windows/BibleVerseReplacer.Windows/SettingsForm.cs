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
        private readonly CheckBox autoUpdateCheckBox = new CheckBox();
        private readonly CheckBox startupCheckBox = new CheckBox();
        private readonly Label dataLabel = new Label();
        private bool recordingShortcut;

        public SettingsForm(Action onPreferencesChanged)
        {
            this.onPreferencesChanged = onPreferencesChanged;
            Text = "Bible Verse Replacer 设置";
            Icon = AppIcons.Current;
            StartPosition = FormStartPosition.CenterScreen;
            Size = new Size(600, 540);
            MinimumSize = new Size(600, 540);
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

            Label author = new Label();
            author.Text = "作者：大侠请留步";
            author.AutoSize = true;
            author.ForeColor = SystemColors.GrayText;
            author.Location = new Point(26, 76);
            Controls.Add(author);

            Label version = new Label();
            version.Text = "版本：" + AppInfo.VersionDisplay;
            version.AutoSize = true;
            version.ForeColor = SystemColors.GrayText;
            version.Location = new Point(26, 96);
            Controls.Add(version);

            AddLabel("仓库", 30, 124);
            TextBox repositoryTextBox = new TextBox();
            repositoryTextBox.ReadOnly = true;
            repositoryTextBox.Text = AppInfo.RepositoryUrl;
            repositoryTextBox.Location = new Point(120, 120);
            repositoryTextBox.Width = 330;
            repositoryTextBox.TabStop = false;
            Controls.Add(repositoryTextBox);

            Button repositoryButton = new Button();
            repositoryButton.Text = "打开";
            repositoryButton.Location = new Point(462, 118);
            repositoryButton.Width = 80;
            repositoryButton.Click += delegate { System.Diagnostics.Process.Start(AppInfo.RepositoryUrl); };
            Controls.Add(repositoryButton);

            AddLabel("快捷键", 30, 160);
            shortcutTextBox.ReadOnly = true;
            shortcutTextBox.Location = new Point(120, 156);
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
            recordButton.Location = new Point(352, 154);
            recordButton.Width = 80;
            recordButton.Click += delegate
            {
                recordingShortcut = true;
                shortcutTextBox.Text = "请按新快捷键...";
                shortcutTextBox.Focus();
            };
            Controls.Add(recordButton);

            AddLabel("输出格式", 30, 202);
            outputFormatComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            outputFormatComboBox.Location = new Point(120, 198);
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

            AddLabel("引用标签", 30, 240);
            referenceLabelComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            referenceLabelComboBox.Location = new Point(120, 236);
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

            AddLabel("组合显示", 30, 278);
            combinedPassageComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            combinedPassageComboBox.Location = new Point(120, 274);
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

            autoUpdateCheckBox.Text = "自动检查更新";
            autoUpdateCheckBox.AutoSize = true;
            autoUpdateCheckBox.Location = new Point(120, 316);
            autoUpdateCheckBox.CheckedChanged += delegate
            {
                UserPreferences.Instance.AutoCheckUpdates = autoUpdateCheckBox.Checked;
            };
            Controls.Add(autoUpdateCheckBox);

            startupCheckBox.Text = "开机自启动";
            startupCheckBox.AutoSize = true;
            startupCheckBox.Location = new Point(120, 352);
            startupCheckBox.CheckedChanged += delegate
            {
                StartupManager.SetEnabled(startupCheckBox.Checked);
            };
            Controls.Add(startupCheckBox);

            AddLabel("经文库", 30, 396);
            dataLabel.AutoSize = true;
            dataLabel.Location = new Point(120, 396);
            Controls.Add(dataLabel);

            Button closeButton = new Button();
            closeButton.Text = "关闭";
            closeButton.Location = new Point(462, 430);
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
            autoUpdateCheckBox.Checked = UserPreferences.Instance.AutoCheckUpdates;
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
