using System;

namespace FormatColumns
{
    internal class ColumnItem : IEquatable<ColumnItem>
    {
        public object Group { get; }
        public object Value { get; }

        public ColumnItem(object groupName, object value)
        {
            this.Group = groupName;
            this.Value = value;
        }

        public bool Equals(ColumnItem other)
            => object.Equals(Group, other.Group)
                && object.Equals(Value, other.Value);

        public override bool Equals(object obj)
            => obj is ColumnItem other
                && this.Equals(other);

        public override int GetHashCode()
            => (Group?.GetHashCode() ?? 0)
                ^ (Value?.GetHashCode() ?? 0);

        public override string ToString()
            => $"{{ {nameof(Value)}: \"{Value}\", {nameof(Group)}: \"{Group}\" }}";
    }
}
