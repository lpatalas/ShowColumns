using System;

namespace ShowColumns.Commands
{
    internal class NoGroup : IEquatable<NoGroup>
    {
        public static readonly NoGroup Instance = new NoGroup();

        private NoGroup()
        {
        }

        public bool Equals(NoGroup other)
            => true;

        public override bool Equals(object obj)
            => obj is NoGroup;

        public override int GetHashCode()
            => 0;

        public override string ToString()
            => "{NoGroup}";
    }
}
