using System;

namespace ShowColumns
{
    internal class ColumnItem : IEquatable<ColumnItem>
    {
        public object Group { get; }
        public string Name { get; }
        public Style Style { get; set; }
        public int Width => Name.Length;

        public ColumnItem(object group, string name, Style style)
        {
            this.Group = group;
            this.Name = name ?? string.Empty;
            this.Style = style;
        }

        public bool Equals(ColumnItem other)
            => object.Equals(Group, other.Group)
                && object.Equals(Name, other.Name);

        public override bool Equals(object obj)
            => obj is ColumnItem other
                && this.Equals(other);

        public override int GetHashCode()
            => (Group?.GetHashCode() ?? 0)
                ^ (Name?.GetHashCode() ?? 0);

        public override string ToString()
            => $"{{ {nameof(Name)}: \"{Name}\", {nameof(Group)}: \"{Group}\" }}";
    }
}
