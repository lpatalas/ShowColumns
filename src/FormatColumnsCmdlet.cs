using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace FormatColumns
{
    [Cmdlet("Format", "Columns")]
	public class FormatColumnsCmdlet : PSCmdlet
	{
        private PropertyAccessor groupByPropertyAccessor;
        private PropertyAccessor itemNamePropertyAccessor;

        private readonly List<ColumnItem> currentGroupItems = new List<ColumnItem>();
        private object currentGroup;

		[Parameter(Mandatory = true, ValueFromPipeline = true)]
		public PSObject InputObject { get; set; }

        [Parameter(Mandatory = true)]
        public object GroupBy { get; set; }

		[Parameter(Mandatory = true)]
		public object Property { get; set; }

        protected override void BeginProcessing()
        {
            groupByPropertyAccessor = new PropertyAccessor(GroupBy, nameof(GroupBy));
            itemNamePropertyAccessor = new PropertyAccessor(Property, nameof(Property));
        }

        protected override void ProcessRecord()
		{
            var groupName = groupByPropertyAccessor.Invoke(InputObject);
            var itemName = itemNamePropertyAccessor.Invoke(InputObject);
            var item = new ColumnItem(groupName, itemName?.ToString());

            if (object.Equals(currentGroup, item.Group))
            {
                currentGroupItems.Add(item);
            }
            else
            {
                FlushCurrentGroup();
                currentGroup = item.Group;
                currentGroupItems.Add(item);
            }
		}

        protected override void EndProcessing()
        {
            FlushCurrentGroup();
        }

        private void FlushCurrentGroup()
        {
            if (currentGroupItems.Any())
            {
                WriteObject($"=== Group {currentGroup} ===");
                WriteColumns(currentGroupItems);

                currentGroupItems.Clear();
            }
        }

        private void WriteColumns(IReadOnlyList<ColumnItem> items)
        {
            var columnWidths = GetBestFittingColumnWidths(
                currentGroupItems,
                availableWidth: Host.UI.RawUI.BufferSize.Width);
            var columnCount = columnWidths.Count;
            var countPerColumn = GetItemCountPerColumn(items.Count, columnCount);

            for (var rowIndex = 0; rowIndex < countPerColumn; rowIndex++)
            {
                for (var columnIndex = 0; columnIndex < columnCount; columnIndex++)
                {
                    var itemIndex = columnIndex * countPerColumn + rowIndex;
                    var item = items[itemIndex];
                    var columnWidth = columnWidths[columnIndex];

                    if (itemIndex < items.Count)
                    {
                        if (columnIndex > 0)
                            Host.UI.Write(" ");

                        Host.UI.Write(item.Name);

                        if (columnIndex < (columnCount - 1))
                        {
                            var padding = columnWidth - item.Width;
                            Host.UI.Write(new string(' ', padding));
                        }
                    }
                }

                if (Host.UI.RawUI.CursorPosition.X > 0)
                    Host.UI.WriteLine();
            }
        }

        private static IReadOnlyList<int> GetBestFittingColumnWidths(
            IReadOnlyList<ColumnItem> items,
            int availableWidth)
        {
            var columnCount = items.Count;
            var foundBestFit = false;

            while (!foundBestFit && (columnCount > 0))
            {
                var columnWidths = GetColumnWidths(items, columnCount);
                var totalWidth = columnWidths.Sum() + (columnWidths.Count - 1);

                if (totalWidth <= availableWidth)
                    return columnWidths;
                else
                    columnCount--;
            }

            return new List<int>(1) { availableWidth };
        }

        private static IReadOnlyList<int> GetColumnWidths(
            IReadOnlyList<ColumnItem> items,
            int columnCount)
        {
            var countPerColumn = GetItemCountPerColumn(items.Count, columnCount);
            var columnWidths = new int[columnCount];

            for (var index = 0; index < items.Count; index++)
            {
                var columnIndex = index / countPerColumn;
                if (columnWidths[columnIndex] < items[index].Width)
                    columnWidths[columnIndex] = items[index].Width;
            }

            return columnWidths;
        }

        private static int GetItemCountPerColumn(int totalItemCount, int columnCount)
        {
            return (totalItemCount + columnCount - 1) / columnCount;
        }
    }
}
