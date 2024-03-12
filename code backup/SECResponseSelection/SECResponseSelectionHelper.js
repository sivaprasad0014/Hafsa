({
	init : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var fileId = myPageRef.state.c__fileId;
        component.set('v.showLoader', true);
        var action = component.get("c.loadData");
        action.setParams({
            'fileId' : fileId,
            'responseType' : component.get('v.responseType')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showLoader', false);
            if (state === "SUCCESS") {
                var r = response.getReturnValue();
                console.log('result..!', r);
                component.set('v.isCustomSearch', r.isCustomSearch);                
                
                var data = r.standardResplist;
                let result = [];
                var filterRecords = [];
                if (data.length > 0) 
                {
                    for(var i = 0; i < data.length; i++)
                    {
                        data[i].title = data[i].Response_Title__c;
                        data[i].status = data[i].Status__c;
                        data[i].approved = data[i].Approved__c;
                        data[i].timesCloned = data[i].Times_Cloned__c;
                        data[i].createdBy = data[i].CreatedBy.Name;
                        data[i].createdDate = data[i].CreatedDate;
                    }
                    component.set("v.originalReferralList_SR", data);
                    component.set("v.referralSearchResult_SR", data);
                    component.set("v.hasSearchResults_SR", true);
                    component.set("v.isSearch_SR", true);
                } 
                else 
                {
                    component.set("v.originalReferralList_SR", []);
                    component.set("v.referralSearchResult_SR", []);
                    component.set("v.hasSearchResults_SR", false);
                }
                component.set("v.paginationPageNumber_SR", 1);
                helper.getTotalCount_SR(component, {});
                helper.getFilterRecord_SR(component, {});
                helper.updateResults_SR(component, {});
            }
            else
            {
                var errors = response.getError();
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    search : function(component, event, helper) {
        var params = {
            'basicSearch' : component.get('v.basicSearch'),
            'titleSearch' : component.get('v.titleSearch'),
            'createdBySearch' : component.get('v.createdBySearch'),
            'approval' : component.get('v.approval'),
            'OCCApproved' : component.get('v.OCCApproved')
        };
        console.log('params..!', params);
        
        component.set('v.showLoader', true);
        var action = component.get("c.filter");
        action.setParams({
            'pStr' : JSON.stringify(params)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showLoader', false);
            let data = [];
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('resp..!', resp);
                //component.set('v.standardWrapResplist', resp.standardWrapResplist);
                component.set('v.isCustomSearch', resp.isCustomSearch);
                data = resp.standardWrapResplist;
                let result = [];
                var filterRecords = [];
                if (data.length > 0) 
                {
                    for(var i = 0; i < data.length; i++)
                    {
                        data[i].title = data[i].resp.Response_Title__c;
                        data[i].approved = data[i].resp.Approved__c;
                        data[i].OCCApproved = data[i].resp.OCC_Approved__c;
                        data[i].timesCloned = data[i].resp.Times_Cloned__c;
                        data[i].createdBy = data[i].resp.CreatedBy.Name;
                        data[i].createdDate = data[i].resp.CreatedDate;
                        data[i].fileNumber = data[i].fileID;
                        data[i].Branch = data[i].resp.Branch__c;
                    }
                    component.set("v.originalReferralList_CR", data);
                    component.set("v.referralSearchResult_CR", data);
                    component.set("v.hasSearchResults_CR", true);
                    component.set("v.isSearch_CR", true);
                } 
                else 
                {
                    component.set("v.originalReferralList_CR", []);
                    component.set("v.referralSearchResult_CR", []);
                    component.set("v.hasSearchResults_CR", false);
                }
                component.set("v.paginationPageNumber_CR", 1);
                helper.getTotalCount_CR(component, {});
                helper.getFilterRecord_CR(component, {});
                helper.updateResults_CR(component, {});
            }
            else
            {
                var errors = response.getError();
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    viewContent : function(component, event, helper) {
        component.set('v.showLoader', true);
        var action = component.get("c.getResponse");
        action.setParams({
            'responseId' : event.currentTarget.dataset.id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showLoader', false);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result..!', result);
                component.set('v.response', result);
                component.set('v.showResponse', true);
            }
            else
            {
                var errors = response.getError();
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    handleResponseType : function(component, event, helper) {
        component.set('v.showLoader', true);
        var action = component.get("c.filterStandard");
        action.setParams({
            'responseType' : component.get('v.responseType')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showLoader', false);
            if (state === "SUCCESS") {
                //var result = response.getReturnValue();
                //console.log('result..!', result);
                //component.set('v.standardResplist', result);
                
                var data = response.getReturnValue();
                let result = [];
                var filterRecords = [];
                if (data.length > 0) 
                {      
                    for(var i = 0; i < data.length; i++)
                    {
                        data[i].title = data[i].Response_Title__c;
                        data[i].status = data[i].Status__c;
                        data[i].approved = data[i].Approved__c;
                        data[i].timesCloned = data[i].Times_Cloned__c;
                        data[i].createdBy = data[i].CreatedBy.Name;
                        data[i].createdDate = data[i].CreatedDate;
                    }
                    component.set("v.originalReferralList_SR", data);
                    component.set("v.referralSearchResult_SR", data);
                    component.set("v.hasSearchResults_SR", true);
                    component.set("v.isSearch_SR", true);
                } 
                else 
                {
                    component.set("v.originalReferralList_SR", []);
                    component.set("v.referralSearchResult_SR", []);
                    component.set("v.hasSearchResults_SR", false);
                }
                component.set("v.paginationPageNumber_SR", 1);
                helper.getTotalCount_SR(component, {});
                helper.getFilterRecord_SR(component, {});
                helper.updateResults_SR(component, {});
            }
            else
            {
                var errors = response.getError();
                alert(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    /*
     * Pagination methods (Custom Responses)
     */
    getTotalCount_CR: function (component, params) {
        let totalList1 = component.get("v.originalReferralList_CR");
        let totalList = [];
        let lastFilter = component.get("v._lastFilter_CR");
        if (lastFilter != "all") {
            let input_filter_str = "^" + lastFilter;
            var filter = new RegExp(input_filter_str, "i");
            totalList = totalList1.filter(
                (a) => a && a.title && filter.test(a.title)
            );
        } else {
            totalList = totalList1;
        }
        let length = totalList.length,
            optionsPageNumber = [],
            totalRecords = 0,
            totalPages = 0;
        let recordsPerPage = component.get("v.paginationOffset_CR");
        recordsPerPage = parseInt(recordsPerPage);
        totalRecords = length;
        totalRecords = parseInt(totalRecords);
        if (isNaN(totalRecords)) {
            totalRecords = 0;
        }
        if (isNaN(recordsPerPage)) {
            recordsPerPage = 25;
        }
        if (totalRecords > 0) {
            if (totalRecords % recordsPerPage != 0) {
                totalPages = parseInt(totalRecords / recordsPerPage) + 1;
            } else {
                totalPages = parseInt(totalRecords / recordsPerPage);
            }
        }
        console.log('totalPages..!',totalPages);
        for (let optionsIndex = 1; optionsIndex <= totalPages; optionsIndex++) {
            let maxRange = optionsIndex * recordsPerPage,
                minRange = (optionsIndex - 1) * recordsPerPage + 1;
            if (maxRange > totalRecords) {
                maxRange = totalRecords;
            }
            optionsPageNumber.push({
                label: minRange + " - " + maxRange,
                value: optionsIndex
            });
        }
        component.set("v.totalRecords_CR", totalRecords);
        component.set("v.totalPages_CR", totalPages);
        component.set("v.optionsPageNumber_CR", optionsPageNumber);
    },
    getFilterRecord_CR: function (component, params) {
        let totalList1 = component.get("v.originalReferralList_CR");
        let totalList = [];
        let lastFilter = component.get("v._lastFilter_CR");
        console.log('..!', JSON.parse(JSON.stringify(totalList1)));
        if (lastFilter != "all") {
            let input_filter_str = "^" + lastFilter;
            var filter = new RegExp(input_filter_str, "i");
            totalList = totalList1.filter(
                (a) => a && a.title && filter.test(a.title)
            );
        } else {
            totalList = totalList1;
        }
        var val = component.get("v.searchParam_CR");        
        if(val){
            var temp = [];
            for(var i = 0; i < totalList.length; i++){
                if(totalList[i].title && totalList[i].title.toUpperCase().includes(val.toUpperCase())){
                    temp.push(totalList[i]);
                }
            }
            totalList = temp;
        }

        let filterList = [];
        let page = component.get("v.paginationPageNumber_CR");
        let recordsPerPage = component.get("v.paginationOffset_CR");
        for (
            var i = (page - 1) * recordsPerPage;
            i < page * recordsPerPage && i < totalList.length;
            i++
        ) {
            filterList.push(totalList[i]);
        }
        component.set("v.referralSearchResult_CR", filterList);
    },
    updateResults_CR: function (component, helper) {
        var allResults = component.get("v.originalReferralList_CR") || [];
        var letters = component.get("v._lastname_chars_CR");
        console.log("letters..!", letters);
        console.log("allResults..!", allResults);
        for (var letter of letters) {
            letter.contains = false;
            for (var a of allResults) {
                if (
                    a.title &&
                    a.title.substring(0, 1).toUpperCase() == letter.letter
                ) {
                    letter.contains = true;
                    break;
                }
            }
        }
        component.set("v._lastname_chars_CR", letters);
    },
    prepareAndPerformSearch_CR: function (component) {
        this.getTotalCount_CR(component);
        this.getFilterRecord_CR(component);
    },
    setParamsAndSearch_CR: function (component, helper) {
        let eventSortBy = component.get("v.sortBy_CR");
        let sortDirection = component.get("v.sortDirection_CR");
        let originalReferralList = component.get("v.originalReferralList_CR");
        let field = eventSortBy;
        let sortAsc = sortDirection == "ASC" ? true : false;
        if (
            field == "title" ||
            field == "Branch" ||
            field == "createdBy" ||
            field == "createdDate" || 
            field == "fileNumber"
        ) {
            originalReferralList.sort(function (a, b) {
                let afield = a[field] ? a[field].toUpperCase() : "";
                let bfield = b[field] ? b[field].toUpperCase() : "";
                var t1 = afield == bfield,
                    t2 = afield > bfield;
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? -1 : 1);
            });
        } else if (field == "approved" || 
                   field == "OCCApproved" || 
                   field == "timesCloned") {
            originalReferralList.sort(function (a, b) {
                let afield = a[field] ? a[field] : "";
                let bfield = b[field] ? b[field] : "";
                var t1 = afield == bfield,
                    t2 = afield > bfield;
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? -1 : 1);
            });
        }
        component.set("v.originalReferralList_CR", originalReferralList);
        helper.getFilterRecord_CR(component, {});
    },
    updateFilterValue_CR: function (component, helper, input_filter_str) {
        helper.prepareAndPerformSearch_CR(component);
        var allResults = component.get("v.originalReferralList_CR") || [];
        var filter = new RegExp(input_filter_str, "i");
        var filtered = allResults.filter(
            (a) => a && a.title && filter.test(a.title)
        );
        let filterList = [];
        let page = component.get("v.paginationPageNumber_CR");
        let recordsPerPage = component.get("v.paginationOffset_CR");
        for (
            var i = (page - 1) * recordsPerPage;
            i < page * recordsPerPage && i < filtered.length;
            i++
        ) {
            filterList.push(filtered[i]);
        }
        component.set("v.referralSearchResult_CR", filterList);
        component.set("v.pageNumber_CR", 1);
    },
    
    /*
     * Pagination methods (Standard Responses)
     */
    getTotalCount_SR: function (component, params) {
        let totalList1 = component.get("v.originalReferralList_SR");
        let totalList = [];
        let lastFilter = component.get("v._lastFilter_SR");
        if (lastFilter != "all") {
            let input_filter_str = "^" + lastFilter;
            var filter = new RegExp(input_filter_str, "i");
            totalList = totalList1.filter(
                (a) => a && a.title && filter.test(a.title)
            );
        } else {
            totalList = totalList1;
        }
        var val = component.get("v.searchParam_SR");
        console.log('val-1..!',val);
        
        if(val){
            var temp = [];
            for(var i = 0; i < totalList.length; i++){
                if(totalList[i].title && totalList[i].title.toUpperCase().includes(val.toUpperCase())){
                    temp.push(totalList[i]);
                }
            }
            totalList = temp;
        }
        let length = totalList.length,
            optionsPageNumber = [],
            totalRecords = 0,
            totalPages = 0;
        let recordsPerPage = component.get("v.paginationOffset_SR");
        recordsPerPage = parseInt(recordsPerPage);
        totalRecords = length;
        totalRecords = parseInt(totalRecords);
        if (isNaN(totalRecords)) {
            totalRecords = 0;
        }
        if (isNaN(recordsPerPage)) {
            recordsPerPage = 25;
        }
        if (totalRecords > 0) {
            if (totalRecords % recordsPerPage != 0) {
                totalPages = parseInt(totalRecords / recordsPerPage) + 1;
            } else {
                totalPages = parseInt(totalRecords / recordsPerPage);
            }
        }
        console.log('totalPages..!',totalPages);
        for (let optionsIndex = 1; optionsIndex <= totalPages; optionsIndex++) {
            let maxRange = optionsIndex * recordsPerPage,
                minRange = (optionsIndex - 1) * recordsPerPage + 1;
            if (maxRange > totalRecords) {
                maxRange = totalRecords;
            }
            optionsPageNumber.push({
                label: minRange + " - " + maxRange,
                value: optionsIndex
            });
        }
        component.set("v.totalRecords_SR", totalRecords);
        component.set("v.totalPages_SR", totalPages);
        component.set("v.optionsPageNumber_SR", optionsPageNumber);
    },

    getFilterRecord_SR: function (component, params) {
        let totalList1 = component.get("v.originalReferralList_SR");
        let totalList = [];
        let lastFilter = component.get("v._lastFilter_SR");
        console.log('..!', JSON.parse(JSON.stringify(totalList1)));
        if (lastFilter != "all") {
            let input_filter_str = "^" + lastFilter;
            var filter = new RegExp(input_filter_str, "i");
            totalList = totalList1.filter(
                (a) => a && a.title && filter.test(a.title)
            );
        } else {
            totalList = totalList1;
        }
        var val = component.get("v.searchParam_SR");
        console.log('val-1..!',val);
        
        if(val){
            var temp = [];
            for(var i = 0; i < totalList.length; i++){
                if(totalList[i].title && totalList[i].title.toUpperCase().includes(val.toUpperCase())){
                    temp.push(totalList[i]);
                }
            }
            totalList = temp;
        }
        
        let filterList = [];
        let page = component.get("v.paginationPageNumber_SR");
        let recordsPerPage = component.get("v.paginationOffset_SR");
        for (
            var i = (page - 1) * recordsPerPage;
            i < page * recordsPerPage && i < totalList.length;
            i++
        ) {
            filterList.push(totalList[i]);
        }
        component.set("v.referralSearchResult_SR", filterList);
    },
    updateResults_SR: function (component, helper) {
        var allResults = component.get("v.originalReferralList_SR") || [];
        var letters = component.get("v._lastname_chars_SR");
        console.log("letters..!", letters);
        console.log("allResults..!", allResults);
        for (var letter of letters) {
            letter.contains = false;
            for (var a of allResults) {
                if (
                    a.title &&
                    a.title.substring(0, 1).toUpperCase() == letter.letter
                ) {
                    letter.contains = true;
                    break;
                }
            }
        }
        component.set("v._lastname_chars_SR", letters);
    },
    prepareAndPerformSearch_SR: function (component) {
        this.getTotalCount_SR(component);
        this.getFilterRecord_SR(component);
    },
    setParamsAndSearch_SR: function (component, helper) {
        let eventSortBy = component.get("v.sortBy_SR");
        let sortDirection = component.get("v.sortDirection_SR");
        let originalReferralList = component.get("v.originalReferralList_SR");
        let field = eventSortBy;
        let sortAsc = sortDirection == "ASC" ? true : false;
        if (
            field == "title" ||
            field == "status" ||            
            field == "createdBy" ||
            field == "createdDate" || 
            field == "fileNumber"
        ) {
            originalReferralList.sort(function (a, b) {
                let afield = a[field] ? a[field].toUpperCase() : "";
                let bfield = b[field] ? b[field].toUpperCase() : "";
                var t1 = afield == bfield,
                    t2 = afield > bfield;
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? -1 : 1);
            });
        } else if (field == "approved" || field == "timesCloned") {
            originalReferralList.sort(function (a, b) {
                let afield = a[field] ? a[field] : "";
                let bfield = b[field] ? b[field] : "";
                var t1 = afield == bfield,
                    t2 = afield > bfield;
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? -1 : 1);
            });
        }
        component.set("v.originalReferralList_SR", originalReferralList);
        helper.getFilterRecord_SR(component, {});
    },
    updateFilterValue_SR: function (component, helper, input_filter_str) {
        helper.prepareAndPerformSearch_SR(component);
        var allResults = component.get("v.originalReferralList_SR") || [];
        var filter = new RegExp(input_filter_str, "i");
        var filtered = allResults.filter(
            (a) => a && a.title && filter.test(a.title)
        );
        let filterList = [];
        let page = component.get("v.paginationPageNumber_SR");
        let recordsPerPage = component.get("v.paginationOffset_SR");
        for (
            var i = (page - 1) * recordsPerPage;
            i < page * recordsPerPage && i < filtered.length;
            i++
        ) {
            filterList.push(filtered[i]);
        }
        component.set("v.referralSearchResult_SR", filterList);
        component.set("v.pageNumber_SR", 1);
    },
})
