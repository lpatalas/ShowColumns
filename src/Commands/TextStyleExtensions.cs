namespace ShowColumns.Commands
{
    internal static class TextStyleExtensions
    {
        public static string WithStyle(this string input, TextStyle style)
        {
            if (style.IsEmpty)
                return input;
            else
                return $"{style}{input}{TextStyle.Reset}";
        }
    }
}
