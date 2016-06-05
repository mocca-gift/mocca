window.onload = init;
    function init(){
      qtext = document.getElementById("qtext");
      btn1 = document.getElementById("btn1");
      btn2 = document.getElementById("btn2");
      ans = document.getElementById("ans");
      postdata1 = document.getElementById("postdata1");
      postdata2 = document.getElementById("postdata2");
      var fade = document.getElementById("fade");
      var loader = document.getElementById("loader");
      
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
              fade.style.display = "block";
              loader.style.display = "block";
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
              fade.style.display = "block";
              loader.style.display = "block";
              ansarray[j] = 2 ;
              postdata1.value=ansarray;
              postdata2.value=Questionid;
              document.frm.submit
            }
          }
        }
    }