using System.Collections;

namespace ShowColumns
{
    internal static class IDictionaryExtensions
    {
        public static object GetValueOrDefault(this IDictionary dictionary, object key)
            => dictionary.Contains(key)
                ? dictionary[key]
                : null;
    }
}
