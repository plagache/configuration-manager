BEGIN {
    FS = ","
    OFS = ","
}
NR == 1 {
    header_column = NF
    print "Header Columns: " header_column > "/dev/stderr"
    print $0
    next
}
{
    n = NF
    original_line = $0

    if (n < header_column) {
        for (i = n + 1; i <= header_column; i++) {
            $i = ""
        }
        line_too_short++
        print "Original (too short):" original_line > "/dev/stderr"
        print "Modified (after padding):" $0 > "/dev/stderr"
        print $0
    }
    else if (n > header_column) {
        line_too_long++
        print $0
    }
    else if (n == header_column) {
        print $0
    }
    line_count++
}
END {
    print "Total lines processed:" line_count > "/dev/stderr"
    print "Lines modified:" line_too_short > "/dev/stderr"
    print "Lines with extra columns:" line_too_long > "/dev/stderr"
}
