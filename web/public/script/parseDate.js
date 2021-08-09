const lang = document.documentElement.lang;
var dates = document.getElementsByClassName("date");

const options = { hour: 'numeric', minute: 'numeric', year: 'numeric',month: 'long', day: 'numeric' };

for (let index = 0; index < dates.length; index++) {
    const element = dates[index];
    const prefix = element.dataset.prefix||"";
    const date = new Date(element.dataset.date);

    const months = ["Jan", "Feb", "Mar","Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    let formatted_date =  months[date.getMonth()] + " " + date.getDate() + ", " + date.getFullYear();
    console.log(formatted_date)

    element.innerHTML = prefix+formatted_date;
}

var litems = document.getElementsByTagName("li");

for(let index = 0; index < litems.length; index++){
    const element = litems[index];
    var text = element.innerText ;

    var pattern = /^\[(?<checked>[ ,x,X])\] /gi;

    var result = pattern.exec(text);

    if(result){
        var {groups: {checked}} = result;
        var code = "check_box_outline_blank";
        element.parentElement.classList.add("checklist");
        element.classList.add("checkbox");
        if(checked !== " "){
            code = "check_box";
        }
        element.innerHTML = element.innerHTML.replace(pattern,`<i class=\"material-icons text-primary mr-2\">${code}</i><p class=\"my-0\">`)+"</p>";
    }
}