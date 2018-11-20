﻿using System.Management.Automation;

namespace ShowColumns
{
    [Cmdlet(VerbsCommon.Show, "Columns")]
    public class ShowColumnsCmdlet : PSCmdlet
    {
        private PropertyAccessor groupByPropertyAccessor;
        private StyleSelector groupHeaderStyleSelector;
        private StyleSelector itemStyleSelector;
        private ColumnItemGroupPresenter itemGroupPresenter;
        private PropertyAccessor itemNamePropertyAccessor;

        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public PSObject InputObject { get; set; }

        [Parameter]
        public object GroupBy { get; set; }

        [Parameter(Mandatory = true)]
        public object Property { get; set; }

        [Parameter]
        public object GroupHeaderStyle { get; set; }

        [Parameter]
        public object ItemStyle { get; set; }

        [Parameter]
        [ValidateRange(1, int.MaxValue)]
        public int MinimumColumnCount { get; set; } = 1;

        protected override void BeginProcessing()
        {
            groupByPropertyAccessor
                = GroupBy != null
                ? PropertyAccessorFactory.Create(GroupBy, nameof(GroupBy))
                : _ => NoGroup.Instance;

            groupHeaderStyleSelector = StyleSelectorFactory.Create(GroupHeaderStyle);
            itemStyleSelector = StyleSelectorFactory.Create(ItemStyle);
            itemNamePropertyAccessor = PropertyAccessorFactory.Create(Property, nameof(Property));

            itemGroupPresenter = new ColumnItemGroupPresenter(
                Host,
                groupHeaderStyleSelector,
                MinimumColumnCount);
        }

        protected override void ProcessRecord()
        {
            var item = new ColumnItem(
                group: groupByPropertyAccessor(InputObject),
                name: itemNamePropertyAccessor(InputObject)?.ToString(),
                style: itemStyleSelector(InputObject));

            itemGroupPresenter.Add(item);
        }

        protected override void EndProcessing()
        {
            itemGroupPresenter.Flush();
        }
    }
}