window.onload = init;
    function init(){
      var qtext = document.getElementById("qtext");
      var btn1 = document.getElementById("btn1");
      var btn2 = document.getElementById("btn2");
      var ans = document.getElementById("ans");
      var postdata1 = document.getElementById("postdata1");
      var postdata2 = document.getElementById("postdata2");
      var num=5;
      var i = 0;
      var j = 0;
      var ansarray = [];
      
      qtext.innerText=Question[i];
      i++;
        btn1.onclick = function(){
          if(i<num){
            qtext.innerText=Question[i];
            ansarray[j]=1;
            i++;
            j++;
          } else {
            if(i==num) {
              i++;
              qtext.style.border="none";
              qtext.innerHTML="<img src='/image/loader.gif'>";
              ansarray[j] = 2 ;
              postdata1.value=ansarray;
              postdata2.value=Questionid;
              document.frm.submit();
            }
          }
        }
        btn2.onclick = function(){
          if(i<num){
            qtext.innerText=Question[i];
            ansarray[j] = 2 ;
            i++;
            j++;
          } else {
            if(i==num) {
              i++;
              qtext.style.border="none";
              qtext.innerHTML="<img src='/image/loader.gif'>";
              ansarray[j] = 2 ;
              postdata1.value=ansarray;
              postdata2.value=Questionid;
              document.frm.submit();
            }
          }
        }
    }