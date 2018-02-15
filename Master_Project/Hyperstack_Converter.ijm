/*
 * Faster and easier way to convert Stack to Hyperstack based on knowing the number of timepoints in hyperstack
 */

waitForUser("Select the image that you want to convert to Hyperstack"); 

Stack.getDimensions(width, height, channels, slices, frames) 

Dialog.create("Configuration");

Dialog.addNumber("How many timepoints in Hyperstack:", 50);

Dialog.show();

nTimepoints = Dialog.getNumber();

new_slices = slices/nTimepoints; 

run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices="+ new_slices +" frames="+ nTimepoints +" display=Color");
