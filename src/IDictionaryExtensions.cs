using System.Collections;

namespace ShowColumns
{
    internal static class IDictionaryExtensions
    {
        public static object GetValueOrDefault(
            this IDictionary dictionary,
            object key,
            object defaultValue = null)
        {
            return dictionary.Contains(key)
                ? dictionary[key]
                : defaultValue;
        }

        public static TValue GetValueOrDefault<TValue>(
            this IDictionary dictionary,
            object key,
            TValue defaultValue = default(TValue))
        {
            if (dictionary.GetValueOrDefault(key) is TValue value)
                return value;
            else
                return defaultValue;
        }
    }
}
