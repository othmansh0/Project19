var Action = function() {};

Action.prototype = {

run: function(parameters) {
    
    //to send two pieces of data to our extension
    
    //"tell iOS the JavaScript has finished preprocessing, and give this data dictionary to the extension." The data that is being sent has the keys "URL" and "title", with the values being the page URL and page title.
    parameters.completionFunction({"URL": document.URL , "title": document.title});

},

finalize: function(parameters) {
    var customJavaScript = parameters["customJavaScript"];
       eval(customJavaScript);
}

};

var ExtensionPreprocessingJS = new Action
