# Workflow: scripts

So far you've been using the console to run code. That's a great place to start, but you'll find it gets cramped pretty quickly as you create more complex ggplot2 graphics and dplyr pipes. To give yourself more room to work, it's a great idea to use the script editor. Open it up either by clicking the File menu, and selecting New File or using the keyboard shortcut Cmd/Ctrl + N. Now you'll see one pane with a tab named 'Untitled-1'. After saving the file as `*.py` you can start a new coding cell by typing `# %%` in your script which will prompt VS Code to give you an interactive Python framework. You will see options to 'Run Cell', 'Run Below', and 'Debug cell' just above the text you typed. Clicking the 'Run Cell' will open the Python Interactive console in a side panel. :


\begin{center}\includegraphics[width=0.75\linewidth]{diagrams/vscode-editor} \end{center}

The script editor is a great place to put code you care about. Keep experimenting in the console, but once you have written code that works and does what you want, put it in the script editor. VS Code does not automatically save the contents of the editor by default. However, you can turn on autosave in [the settings](https://code.visualstudio.com/docs/editor/codebasics#_save-auto-save) and when you quit VS Code it will save and automatically load it when you re-open. Nevertheless, it's a good idea to save your scripts regularly and to back them up.

## Running code

The script editor is also a great place to build up complex Altair charts or long sequences of pandas manipulations. The key to using the script editor effectively is to memorise one of the most important keyboard shortcuts: shift + Enter. This executes the current cell from your Python script in the console. 

I recommend that you always start your script with the packages that you need. That way, if you share your code with others, they can easily see what packages they need to install. Note, however, that you should never include `os.chdir()` in a script that you share. It's very antisocial to change settings on someone else's computer!

When working through future chapters, I highly recommend starting in the editor and practicing your keyboard shortcuts. Over time, sending code to the console in this way will become so natural that you won't even think about it.
