({
	doInit : function(component, event, helper) {
        var alphabets = [
            {"letter" : "A", "contains" : false},
            {"letter" : "B", "contains" : false},
            {"letter" : "C", "contains" : false},
            {"letter" : "D", "contains" : false},
            {"letter" : "E", "contains" : false},
            {"letter" : "F", "contains" : false},
            {"letter" : "G", "contains" : false},
            {"letter" : "H", "contains" : false},
            {"letter" : "I", "contains" : false},
            {"letter" : "J", "contains" : false},
            {"letter" : "K", "contains" : false},
            {"letter" : "L", "contains" : false},
            {"letter" : "M", "contains" : false},
            {"letter" : "N", "contains" : false},
            {"letter" : "O", "contains" : false},
            {"letter" : "P", "contains" : false},
            {"letter" : "Q", "contains" : false},
            {"letter" : "R", "contains" : false},
            {"letter" : "S", "contains" : false},
            {"letter" : "T", "contains" : false},
            {"letter" : "U", "contains" : false},
            {"letter" : "V", "contains" : false},
            {"letter" : "W", "contains" : false},
            {"letter" : "X", "contains" : false},
            {"letter" : "Y", "contains" : false},
            {"letter" : "Z", "contains" : false}
        ];
        component.set("v._lastname_chars_CR", alphabets);
        component.set("v._lastname_chars_SR", alphabets);
        helper.init(component, event, helper);        
    },
    handleResponseEvent : function(component, event, helper) {
        var mode = event.getParam('mode');
        if(mode == 'CUSTOM RESPONSE'){
            helper.search(component, event, helper);
        }
        else if(mode == 'STANDARD RESPONSE'){
            helper.init(component, event, helper);
        }
    },
    hideModel : function(component, event, helper) {
        component.set('v.showModel', false);
    },
    save : function(component, event, helper) {
        helper.save(component, event, helper);
    },
    search : function(component, event, helper) {
        var basicSearch = component.get('v.basicSearch');
        var titleSearch = component.get('v.titleSearch');
        var createdBySearch = component.get('v.createdBySearch');
        var OCCApproved = component.get('v.OCCApproved');
        
        var tLen = titleSearch ? titleSearch.length : 0;
        var cLen = createdBySearch ? createdBySearch.length : 0;
        
        if((basicSearch.length == 0 || basicSearch.length == 1) && titleSearch.length == 0 && createdBySearch.length == 0 && OCCApproved == false)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": '',
                "message": "The search string must be at least 2 characters long",
                "type" : "error",
                "mode" : "sticky"
            });
            toastEvent.fire();
            return;
        }
        helper.search(component, event, helper);
    },
    reset : function(component, event, helper) {
        component.set('v.basicSearch', '');
        component.set('v.titleSearch', '');
        component.set('v.createdBySearch', '');
        component.set('v.approval', 'Both');
        component.set('v.OCCApproved', false);
        helper.init(component, event, helper);
    },
    cancel : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var fileId = myPageRef.state.c__fileId;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": fileId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    viewContent : function(component, event, helper) {
        helper.viewContent(component, event, helper);        
    },
    closeResponse : function(component, event, helper) {
        component.set('v.showResponse', false);
    },
    clone_CR : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var respId = event.currentTarget.dataset.id;
        var fileId = myPageRef.state.c__fileId;
        component.find("SECResponseCreation").loadFromSelection(fileId, respId, "CUSTOM RESPONSE");        
    },
    clone_SR : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var respId = event.currentTarget.dataset.id;
        var fileId = myPageRef.state.c__fileId;
        console.log('respId..!', respId);
        console.log('fileId..!', fileId);
        component.find("SECResponseCreation").loadFromSelection(fileId, respId, "STANDARD RESPONSE");        
    },
    handleResponseType : function(component, event, helper) {
        helper.handleResponseType(component, event, helper);
    },
    
    
    /* 
     * Pagination methods (Custom Responses)
     */
    handlePaginationFirst_CR: function (component, event, helper) {
        component.set("v.paginationPageNumber_CR", 1);
        helper.prepareAndPerformSearch_CR(component);
    },
    handlePaginationPrevious_CR: function (component, event, helper) {
        let paginationPageNumber = component.get("v.paginationPageNumber_CR");
        paginationPageNumber = parseInt(paginationPageNumber);
        if (paginationPageNumber > 1) {
            paginationPageNumber -= 1;
            component.set("v.paginationPageNumber_CR", paginationPageNumber);
            helper.prepareAndPerformSearch_CR(component);
        }
    },
    handlePaginationNext_CR: function (component, event, helper) {
        let paginationPageNumber = component.get("v.paginationPageNumber_CR"),
            totalPages = component.get("v.totalPages_CR");
        paginationPageNumber = parseInt(paginationPageNumber);
        totalPages = parseInt(totalPages);
        if (paginationPageNumber < totalPages) {
            paginationPageNumber += 1;
            component.set("v.paginationPageNumber_CR", paginationPageNumber);
            helper.prepareAndPerformSearch_CR(component);
        }
    },
    handlePaginationLast_CR: function (component, event, helper) {
        var optionsPageNumber = component.get('v.optionsPageNumber_CR');
        component.set("v.paginationPageNumber_CR", optionsPageNumber.length);
        helper.prepareAndPerformSearch_CR(component);
    },
    handlePaginationPageSelection_CR: function (component, event, helper) {
        let paginationPageNumber = component.get("v.paginationPageNumber_CR"),
            eventValue = event.getSource().get("v.value");
        component.set("v.paginationPageNumber_CR", parseInt(eventValue));
        helper.prepareAndPerformSearch_CR(component);
    },
    handleFilterLastNameInitial_CR: function (component, event, helper) {
        var src = event.target && event.target.closest("a");
        if (src) {
            component.set("v.paginationPageNumber_CR", 1);
            var letter = src.getAttribute("data-initial");
            var active = src.getAttribute("data-active");
            if (letter == "all") {
                component.set("v._filter_CR", "");
                component.set("v._lastFilter_CR", "all");
                helper.updateFilterValue_CR(component, helper);
            } else if (active == "true" && letter) {
                component.set("v._lastFilter_CR", letter);
                helper.updateFilterValue_CR(component, helper, "^" + letter);
            }
        }
    },
    handleSortBy_CR: function (component, event, helper) {
        let eventSortBy = event.currentTarget.dataset.sort,
            sortBy = component.get("v.sortBy_CR");
        if (eventSortBy) {
            if (sortBy == eventSortBy) {
                let sortDirection = component.get("v.sortDirection_CR");
                component.set(
                    "v.sortDirection_CR",
                    sortDirection == "ASC" ? "DESC" : "ASC"
                );
            } else {
                component.set("v.sortBy_CR", eventSortBy);
                component.set("v.sortDirection_CR", "DESC");
            }
            helper.setParamsAndSearch_CR(component, helper);
        }
    },
    
    /* 
     * Pagination methods (Standard Responses)
     */
    handlePaginationFirst_SR: function (component, event, helper) {
        component.set("v.paginationPageNumber_SR", 1);
        helper.prepareAndPerformSearch_SR(component);
    },
    handlePaginationPrevious_SR: function (component, event, helper) {
        let paginationPageNumber = component.get("v.paginationPageNumber_SR");
        paginationPageNumber = parseInt(paginationPageNumber);
        if (paginationPageNumber > 1) {
            paginationPageNumber -= 1;
            component.set("v.paginationPageNumber_SR", paginationPageNumber);
            helper.prepareAndPerformSearch_SR(component);
        }
    },
    handlePaginationNext_SR: function (component, event, helper) {
        let paginationPageNumber = component.get("v.paginationPageNumber_SR"),
            totalPages = component.get("v.totalPages_SR");
        paginationPageNumber = parseInt(paginationPageNumber);
        totalPages = parseInt(totalPages);        
        if (paginationPageNumber < totalPages) {
            paginationPageNumber += 1;
            component.set("v.paginationPageNumber_SR", paginationPageNumber);
            helper.prepareAndPerformSearch_SR(component);
        }
    },
    handlePaginationLast_SR: function (component, event, helper) {
        var optionsPageNumber = component.get('v.optionsPageNumber_SR');
        component.set("v.paginationPageNumber_SR", optionsPageNumber.length);
        helper.prepareAndPerformSearch_SR(component);
    },
    handlePaginationPageSelection_SR: function (component, event, helper) {
        let paginationPageNumber = component.get("v.paginationPageNumber_SR"),
            eventValue = event.getSource().get("v.value");
        component.set("v.paginationPageNumber_SR", parseInt(eventValue));
        helper.prepareAndPerformSearch_SR(component);
    },
    handleFilterLastNameInitial_SR: function (component, event, helper) {
        var src = event.target && event.target.closest("a");
        if (src) {
            component.set("v.paginationPageNumber_SR", 1);
            var letter = src.getAttribute("data-initial");
            var active = src.getAttribute("data-active");
            if (letter == "all") {
                component.set("v._filter_SR", "");
                component.set("v._lastFilter_SR", "all");
                helper.updateFilterValue_SR(component, helper);
            } else if (active == "true" && letter) {
                component.set("v._lastFilter_SR", letter);
                helper.updateFilterValue_SR(component, helper, "^" + letter);
            }
        }
    },
    handleSortBy_SR: function (component, event, helper) {
        let eventSortBy = event.currentTarget.dataset.sort,
            sortBy = component.get("v.sortBy_SR");
        if (eventSortBy) {
            if (sortBy == eventSortBy) {
                let sortDirection = component.get("v.sortDirection_SR");
                component.set(
                    "v.sortDirection_SR",
                    sortDirection == "ASC" ? "DESC" : "ASC"
                );
            } else {
                component.set("v.sortBy_SR", eventSortBy);
                component.set("v.sortDirection_SR", "DESC");
            }
            helper.setParamsAndSearch_SR(component, helper);
        }
    },
    search_SR: function (component, event, helper) {
        component.set("v.paginationPageNumber_SR", 1);
        helper.prepareAndPerformSearch_SR(component);
    },

    search_CR : function (component, event, helper) {
        console.log('search custom');
      //  component.set("v.paginationPageNumber_SR", 1);
       // helper.prepareAndPerformSearch_SR(component);
    }
})
