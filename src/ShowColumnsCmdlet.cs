using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace ShowColumns
{
    [Cmdlet(VerbsCommon.Show, "Columns")]
    public class ShowColumnsCmdlet : PSCmdlet
    {
        private PropertyAccessor groupByPropertyAccessor;
        private CustomColorSelector itemColorSelector;
        private PropertyAccessor itemNamePropertyAccessor;

        private readonly List<ColumnItem> currentGroupItems = new List<ColumnItem>();
        private object currentGroup;

        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public PSObject InputObject { get; set; }

        [Parameter]
        public object GroupBy { get; set; }

        [Parameter(Mandatory = true)]
        public object Property { get; set; }

        [Parameter]
        public CustomColor GroupHeaderColor { get; set; } = CustomColor.Default;

        [Parameter]
        public ScriptBlock ItemColors { get; set; }

        [Parameter]
        [ValidateRange(1, int.MaxValue)]
        public int MinimumColumnCount { get; set; } = 1;

        protected override void BeginProcessing()
        {
            groupByPropertyAccessor
                = GroupBy != null
                ? PropertyAccessorFactory.Create(GroupBy, nameof(GroupBy))
                : _ => NoGroup.Instance;

            itemColorSelector = CustomColorSelectorFactory.Create(ItemColors);
            itemNamePropertyAccessor = PropertyAccessorFactory.Create(Property, nameof(Property));
        }

        protected override void ProcessRecord()
        {
            var itemColor = itemColorSelector(InputObject);
            var groupName = groupByPropertyAccessor.Invoke(InputObject);
            var itemName = itemNamePropertyAccessor.Invoke(InputObject);
            var item = new ColumnItem(itemColor, groupName, itemName?.ToString());

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
                if (currentGroup != NoGroup.Instance)
                {
                    Host.UI.WriteLine(
                        GroupHeaderColor.Foreground,
                        GroupHeaderColor.Background,
                        currentGroup.ToString());
                }

                ColumnsPresenter.WriteColumns(
                    Host,
                    currentGroupItems,
                    MinimumColumnCount);

                currentGroupItems.Clear();
            }
        }
    }
}
