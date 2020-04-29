import cmark

/// A CommonMark document.
public final class Document: Node {
    /// Options for parsing CommonMark text.
    public struct ParsingOptions: OptionSet {
        public var rawValue: Int32

        public init(rawValue: Int32 = CMARK_OPT_DEFAULT) {
            self.rawValue = rawValue
        }

        /**
         Convert ASCII punctuation characters
         to "smart" typographic punctuation characters.

         - Straight quotes (" and ')
           become curly quotes (“ ” and ‘ ’)
         - Dashes (-- and ---) become
           en-dashes (–) and em-dashes (—)
         - Three consecutive full stops (...) become an ellipsis (…)
         */
        public static let smart = RenderingOptions(rawValue: CMARK_OPT_SMART)
    }

    /// A position within a document.
    public struct Position: Hashable {
        /**
         The line number.

         Line numbers start at 1 and increase monotonically.
         */
        public var line: Int

        /**
         The line number.

         Column numbers start at 1 and increase monotonically.
        */
        public var column: Int
    }

    /// An error when creating a document.
    public enum Error: Swift.Error {
        /// A document couldn't be constructed with the provided source.
        case invalid
    }

    override class var cmark_node_type: cmark_node_type { return CMARK_NODE_DOCUMENT }

    /**
     Creates a document from a CommonMark string.

     - Parameter commonmark: A CommonMark string.
     - Throws:
        - `Document.Error.invalid`
          if a document couldn't be constructed with the provided source.
     */
    public convenience init(_ commonmark: String, options: ParsingOptions = []) throws {
        guard let cmark_node = cmark_parse_document(commonmark, commonmark.utf8.count, 0) else {
            throw Error.invalid
        }

        self.init(cmark_node)
    }

    // MARK: - Rendering

    /// Formats for rendering a document.
    public enum RenderingFormat {
        /// CommonMark
        case commonmark

        /// HTML
        case html

        /// XML
        case xml

        /// LaTeX
        case latex

        /// Manpage
        case manpage
    }

    /// Options for rendering a CommonMark document.
    public struct RenderingOptions: OptionSet {
        public var rawValue: Int32

        public init(rawValue: Int32 = CMARK_OPT_DEFAULT) {
            self.rawValue = rawValue
        }

        /**
         Render raw HTML and "unsafe" links.

         A link is considered to be "unsafe"
         if its scheme is `javascript:`, `vbscript:`, or `file:`,
         or if its scheme is `data:`
         and the MIME type of the encoded data isn't one of the following:

         - `image/png`
         - `image/gif`
         - `image/jpeg`
         - `image/webp`

         By default,
         raw HTML is replaced by a placeholder HTML comment.
         Unsafe links are replaced by empty strings.

         - Important: This option has an effect only when rendering HTML.
         */
        public static let unsafe = RenderingOptions(rawValue: CMARK_OPT_UNSAFE)

        /**
         Render softbreak elements as spaces.

         - Important: This option has no effect when rendering XML.
         */
        public static let noBreaks = RenderingOptions(rawValue: CMARK_OPT_NOBREAKS)

        /**
         Render softbreak elements as hard line breaks.

         - Important: This option has no effect when rendering XML.
         */
        public static let hardBreaks = RenderingOptions(rawValue: CMARK_OPT_HARDBREAKS)

        /**
         Include a `data-sourcepos` attribute on all block elements
         to map the rendered output to the source input.

         - Important: This option has an effect only when rendering HTML or XML.
         */
        public static let includeSourcePosition = RenderingOptions(rawValue: CMARK_OPT_SOURCEPOS)
    }
}

// MARK: - Comparable

extension Document.Position: Comparable {
    public static func < (lhs: Document.Position, rhs: Document.Position) -> Bool {
        return lhs.line < rhs.line || (lhs.line == rhs.line && lhs.column < rhs.column)
    }
}
