using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Host;

namespace ShowColumns
{
    internal class ColumnItemGroupPresenter
    {
        private object currentGroup;
        private readonly List<ColumnItem> currentGroupItems = new List<ColumnItem>();
        private readonly TextStyleSelector groupHeaderStyleSelector;
        private readonly PSHost host;
        private bool isFirstGroup = true;
        private readonly int minimumColumnCount;

        public ColumnItemGroupPresenter(
            PSHost host,
            TextStyleSelector groupHeaderStyleSelector,
            int minimumColumnCount)
        {
            this.host = host;
            this.groupHeaderStyleSelector = groupHeaderStyleSelector;
            this.minimumColumnCount = minimumColumnCount;
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
                        host.UI.WriteLine();

                    var groupHeaderStyle = groupHeaderStyleSelector(currentGroup);
                    host.UI.WriteLine(
                        currentGroup
                            .ToString()
                            .WithStyle(groupHeaderStyle));
                }

                ColumnsPresenter.WriteColumns(
                    host,
                    currentGroupItems,
                    minimumColumnCount);

                currentGroupItems.Clear();
                isFirstGroup = false;
            }
        }
    }
}
