using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Host;

namespace ShowColumns
{
    internal class ColumnItemGroupPresenter
    {
        private object currentGroup;
        private readonly List<ColumnItem> currentGroupItems = new List<ColumnItem>();
        private readonly CustomColorSelector groupHeaderColorSelector;
        private readonly PSHost host;
        private readonly int minimumColumnCount;

        public ColumnItemGroupPresenter(
            PSHost host,
            CustomColorSelector groupHeaderColorSelector,
            int minimumColumnCount)
        {
            this.host = host;
            this.groupHeaderColorSelector = groupHeaderColorSelector;
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
                    var groupHeaderColor = groupHeaderColorSelector(currentGroup);
                    host.UI.WriteLine(
                        groupHeaderColor.Foreground,
                        groupHeaderColor.Background,
                        currentGroup.ToString());
                }

                ColumnsPresenter.WriteColumns(
                    host,
                    currentGroupItems,
                    minimumColumnCount);

                currentGroupItems.Clear();
            }
        }
    }
}
