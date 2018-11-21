using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Host;

namespace ShowColumns.Commands
{
    internal class ColumnItemGroupPresenter
    {
        private object currentGroup;
        private readonly List<ColumnItem> currentGroupItems = new List<ColumnItem>();
        private readonly TextStyleSelector groupHeaderStyleSelector;
        private readonly PSHost host;
        private bool isFirstGroup = true;
        private readonly int minimumColumnCount;
        private readonly LineWriter lineWriter;

        public ColumnItemGroupPresenter(
            PSHost host,
            TextStyleSelector groupHeaderStyleSelector,
            int minimumColumnCount,
            LineWriter lineWriter)
        {
            this.host = host;
            this.groupHeaderStyleSelector = groupHeaderStyleSelector;
            this.minimumColumnCount = minimumColumnCount;
            this.lineWriter = lineWriter;
        }

        public void Add(ColumnItem item)
        {
            if (object.Equals(currentGroup, item.Group))
            {
                currentGroupItems.Add(item);
            }
            else
            {
                Flush();
                currentGroup = item.Group;
                currentGroupItems.Add(item);
            }
        }

        public void Flush()
        {
            if (currentGroupItems.Any())
            {
                if (currentGroup != NoGroup.Instance)
                {
                    if (!isFirstGroup)
                        lineWriter.FinishLine();

                    if (currentGroup != null)
                    {
                        var groupHeaderStyle = groupHeaderStyleSelector(currentGroup);
                        var text = currentGroup
                            .ToString()
                            .WithStyle(groupHeaderStyle);

                        lineWriter.Write(text);
                        lineWriter.FinishLine();
                    }
                }

                ColumnsPresenter.WriteColumns(
                    host,
                    currentGroupItems,
                    minimumColumnCount,
                    lineWriter);

                currentGroupItems.Clear();
                isFirstGroup = false;
            }
        }
    }
}
