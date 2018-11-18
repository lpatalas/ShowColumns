using System.Management.Automation;

namespace ShowColumns
{
    [Cmdlet(VerbsCommon.Show, "Columns")]
    public class ShowColumnsCmdlet : PSCmdlet
    {
        private PropertyAccessor groupByPropertyAccessor;
        private CustomColorSelector groupHeaderColorSelector;
        private CustomColorSelector itemColorSelector;
        private ColumnItemGroupPresenter itemGroupPresenter;
        private PropertyAccessor itemNamePropertyAccessor;

        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public PSObject InputObject { get; set; }

        [Parameter]
        public object GroupBy { get; set; }

        [Parameter(Mandatory = true)]
        public object Property { get; set; }

        [Parameter]
        public object GroupHeaderColor { get; set; }

        [Parameter]
        public object ItemColor { get; set; }

        [Parameter]
        [ValidateRange(1, int.MaxValue)]
        public int MinimumColumnCount { get; set; } = 1;

        protected override void BeginProcessing()
        {
            groupByPropertyAccessor
                = GroupBy != null
                ? PropertyAccessorFactory.Create(GroupBy, nameof(GroupBy))
                : _ => NoGroup.Instance;

            groupHeaderColorSelector = CustomColorSelectorFactory.Create(GroupHeaderColor);
            itemColorSelector = CustomColorSelectorFactory.Create(ItemColor);
            itemNamePropertyAccessor = PropertyAccessorFactory.Create(Property, nameof(Property));

            itemGroupPresenter = new ColumnItemGroupPresenter(
                Host,
                groupHeaderColorSelector,
                MinimumColumnCount);
        }

        protected override void ProcessRecord()
        {
            var item = new ColumnItem(
                color: itemColorSelector(InputObject),
                group: groupByPropertyAccessor(InputObject),
                name: itemNamePropertyAccessor(InputObject)?.ToString());

            itemGroupPresenter.Add(item);
        }

        protected override void EndProcessing()
        {
            itemGroupPresenter.Flush();
        }
    }
}
