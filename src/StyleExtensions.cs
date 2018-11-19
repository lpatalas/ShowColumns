using System;
using System.Text;

namespace ShowColumns
{
    internal static class StyleExtensions
    {
        private const char ESC = (char)0x1b;
        private static readonly string Reset = $"{ESC}[0m";

        public static string WithStyle(this string input, Style style)
        {
            if (style.IsDefault)
                return input;

            var stringBuilder = new StringBuilder(input.Length + 20);
            stringBuilder.Append(ESC);
            stringBuilder.Append('[');

            if (style.Foreground.HasValue)
                stringBuilder.Append(ForegroundColorCode(style.Foreground.Value));

            if (style.Background.HasValue)
            {
                if (style.Foreground.HasValue)
                    stringBuilder.Append(';');
                stringBuilder.Append(BackgroundColorCode(style.Background.Value));
            }
            
            if (style.Underline)
                stringBuilder.Append(";4");

            stringBuilder.Append('m');
            stringBuilder.Append(input);
            stringBuilder.Append(Reset);

            return stringBuilder.ToString();
        }

        private static int BackgroundColorCode(ConsoleColor color)
            => ForegroundColorCode(color) + 10;

        private static int ForegroundColorCode(ConsoleColor color)
        {
            switch (color)
            {
                case ConsoleColor.Black: return 30;
                case ConsoleColor.Blue: return 94;
                case ConsoleColor.Cyan: return 96;
                case ConsoleColor.DarkBlue: return 34;
                case ConsoleColor.DarkCyan: return 36;
                case ConsoleColor.DarkGray: return 90;
                case ConsoleColor.DarkGreen: return 32;
                case ConsoleColor.DarkMagenta: return 35;
                case ConsoleColor.DarkRed: return 31;
                case ConsoleColor.DarkYellow: return 33;
                case ConsoleColor.Gray: return 37;
                case ConsoleColor.Green: return 92;
                case ConsoleColor.Magenta: return 95;
                case ConsoleColor.Red: return 91;
                case ConsoleColor.White: return 97;
                case ConsoleColor.Yellow: return 93;
                default: return 37;
            }
        }
    }
}
