---
name: code review guideline skill
description: describe how to review code with best practices, use when user ask for help with code review or you need to implement the code
---

# code review guidelines
the document outlines the best practices for what a good code looks like, a good codebase should follow these guidelines.

## when to use this skill
when user ask to review code, ask help with the code review or when you need to implement the code

## guidelines
+ don't write any comments that describe what the code does in the codebase, write comments only if the code is not obvious or if the user asks for it
+ write comments only to describe why the code is written a certain way, not what it does
+ avoid unclear variable names, use names that are clear and concise
+ avoid multi layer nested if statements or for loops, refactor them with functions or classes
+ use third party packages whenever possible, don't reinvent the wheel
+ always making sure abstraction layer is constructed between different layers of the codebase, don't put all the logic in the same layer
+ log the error and success messages in proper location whenever possible
+ make type alias whenever possible, simple int, string cannot easily tell the difference between them, use type alias to make it clear, for example, use `UserId` instead of `int`
