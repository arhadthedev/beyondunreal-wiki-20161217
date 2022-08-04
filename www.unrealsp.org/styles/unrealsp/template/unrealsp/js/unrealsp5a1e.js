$(document).ready(function(){
    match = false;
    
    $("ul.topnav li").hover(
    function() {
        var element = $(this).find("ul.subnav");
        //Following events are applied to the submenu itself (moving submenu up and down)
        if ( match == true ) {
            element.stop(true, false).slideDown(300); //Drop down the submenu on click }
        }
        else {
            element.show(); //Drop down the submenu on click }
        }
    },
    function() {
        var element = $(this).parent().find("ul.subnav");
        if ( match == true ) {
            element.stop(true, false).slideUp(150); //Drop down the submenu on click }
        }
        else {
            element.hide(); //Drop down the submenu on click }
        }   
        
    });

    enquire.register("screen and (min-width:62em)", { // <-- the bracket was here
        match : function() {
            match = true;
        },
        unmatch : function() {
            match = false;
        } 
    }); // Note the closing round bracket here    
});