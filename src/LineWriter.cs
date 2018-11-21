using System.Management.Automation;
using System.Text;

namespace ShowColumns
{
    internal class LineWriter
    {
        private static readonly string[] pshostTags = new[] { "PSHOST" };

        private readonly Cmdlet cmdlet;
        private readonly StringBuilder currentLine;

        public LineWriter(PSCmdlet cmdlet)
        {
            var bufferWidth = cmdlet.Host.UI.RawUI.BufferSize.Width;

            this.cmdlet = cmdlet;
            this.currentLine = new StringBuilder(bufferWidth * 2);
        }

        public void Write(string message)
            => currentLine.Append(message);

        public void WritePadding(int spaceCount)
            => currentLine.Append(' ', spaceCount);

        public void FinishLine()
        {
            var message = currentLine.ToString();

            var informationMessage = new HostInformationMessage
            {
                Message = message,
                NoNewLine = false
            };

            cmdlet.WriteInformation(informationMessage, pshostTags);
            currentLine.Clear();
        }
    }
}
