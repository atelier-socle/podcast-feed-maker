/// Standard exit codes for CLI commands.
enum ExitCodes {

    /// Successful execution.
    static let success: Int32 = 0

    /// An error occurred (parse failure, IO error, validation errors).
    static let error: Int32 = 1

    /// Warnings only (no errors).
    static let warningsOnly: Int32 = 2
}
