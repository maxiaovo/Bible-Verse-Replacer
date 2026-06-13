using System;
using System.IO;
using System.Net;
using System.Reflection;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Threading.Tasks;

namespace BibleVerseReplacer.Windows
{
    internal sealed class UpdateCheckResult
    {
        public string CurrentVersion { get; set; }
        public string LatestVersion { get; set; }
        public string ReleaseUrl { get; set; }
        public bool IsUpdateAvailable { get; set; }
        public Exception Error { get; set; }
    }

    internal sealed class UpdateChecker
    {
        private const string LatestReleaseApiUrl = "https://api.github.com/repos/maxiaovo/Bible-Verse-Replacer/releases/latest";

        public void CheckAsync(Action<UpdateCheckResult> callback)
        {
            Task.Factory.StartNew(Check).ContinueWith(task =>
            {
                if (task.IsFaulted)
                {
                    callback(new UpdateCheckResult
                    {
                        CurrentVersion = CurrentVersion,
                        Error = task.Exception == null ? null : task.Exception.GetBaseException()
                    });
                    return;
                }

                callback(task.Result);
            });
        }

        private static UpdateCheckResult Check()
        {
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(LatestReleaseApiUrl);
            request.UserAgent = "BibleVerseReplacer";
            request.Accept = "application/vnd.github+json";
            request.Timeout = 10000;

            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            using (Stream stream = response.GetResponseStream())
            {
                DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(GitHubRelease));
                GitHubRelease release = (GitHubRelease)serializer.ReadObject(stream);

                string current = CurrentVersion;
                string latest = NormalizeVersion(release.TagName);
                return new UpdateCheckResult
                {
                    CurrentVersion = current,
                    LatestVersion = latest,
                    ReleaseUrl = release.HtmlUrl,
                    IsUpdateAvailable = CompareVersions(latest, current) > 0
                };
            }
        }

        private static string CurrentVersion
        {
            get
            {
                Version version = Assembly.GetExecutingAssembly().GetName().Version;
                return version.Major + "." + version.Minor + "." + version.Build;
            }
        }

        private static string NormalizeVersion(string value)
        {
            return (value ?? string.Empty).Trim().TrimStart('v', 'V');
        }

        private static int CompareVersions(string left, string right)
        {
            int[] leftParts = VersionParts(left);
            int[] rightParts = VersionParts(right);
            int count = Math.Max(leftParts.Length, rightParts.Length);

            for (int index = 0; index < count; index++)
            {
                int leftValue = index < leftParts.Length ? leftParts[index] : 0;
                int rightValue = index < rightParts.Length ? rightParts[index] : 0;
                int comparison = leftValue.CompareTo(rightValue);
                if (comparison != 0)
                {
                    return comparison;
                }
            }

            return 0;
        }

        private static int[] VersionParts(string version)
        {
            string[] rawParts = (version ?? string.Empty).Split('.');
            int[] parts = new int[rawParts.Length];
            for (int index = 0; index < rawParts.Length; index++)
            {
                int value;
                parts[index] = int.TryParse(rawParts[index], out value) ? value : 0;
            }
            return parts;
        }

        [DataContract]
        private sealed class GitHubRelease
        {
            [DataMember(Name = "tag_name")]
            public string TagName { get; set; }

            [DataMember(Name = "html_url")]
            public string HtmlUrl { get; set; }
        }
    }
}
