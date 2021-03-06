/**
    D implementation of Myers Diff, based on port from the Java implementation of Myers Diff algorithm, based on a port
    from the C# implementation done by Nicholas Butler at $(LINK http://simplygenius.net/Article/DiffTutorial1) or
    $(LINK http://www.codeproject.com/Articles/42279/Investigating-Myers-diff-algorithm-Part-1-of-2)

    Authors: ttldtor
    Copyright: © 2019-2021 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
 */

module diff;

public import diff.v;
public import diff.snake;
public import diff.snake_pair;
public import diff.lcs_snake_provider;
public import diff.results;
public import diff.linear_comparator;
public import diff.greedy_comparator;
