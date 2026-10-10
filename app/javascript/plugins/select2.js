import $ from 'jquery';
import 'select2';

const initSelect2  = () => {
    console.log("test")
    $(document).ready(function() {
        $('.js-example-basic-single').select2({
            minimumResultsForSearch: Infinity
        });
    });
}

export { initSelect2 }