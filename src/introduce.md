title: About:me
discord: true

# 🌟 qwreey/about?q=안녕_세상!

<div class="center" style="font-size:1.2em"></div>

웹디자인, 프론트엔드, 백엔드, 리눅스 서버관리, 각종 코딩 등 여러분야에 관심을 가지고 시간을 투자하는 고등학생입니다.
남들 게임할 시간에 코딩하고 연구하는 사람으로 모든게 야매이지만, 수년간의 경험 만큼 남들을 가르쳐주고 여러 일을 도와주기도 합니다.  
주 관심 분야는 백엔드&프론트 엔드이고 지금 보이는 이런 페이지부터 electron 을 이용한 데스크탑 앱, 서버 api 도 만듭니다. 리눅스에 미쳐있어서 메인컴에 리눅스를 쓰는 사람이기도 합니다  
??? question "할줄아는거?"
    <br>
    <div class="center">사용언어</div>
    <div class="center" style="font-size:0.8rem">Golang, ts&js, java(찍먹), python, html&css&markdown, C&C++<br>lua(정복? 지금 이 사이트도 루아기반이다), bashscript&make(언어야 이거?)</div>
    <br>
    <div class="center">그리고...<br><span style="font-size:1.2em">언어는 javascript 와 typescript 를 가장 사랑합니다</span>nodeJS !</div>
    <br>
    <div class="center">기술이랄까...</div>
    <div class="center" style="font-size:0.8rem">JS 라이브러리 (fastify, electron, djs, ...), vite, 어도비XD^&Figma(디자인도구)<br>git, 각종 리눅스 도구(vim..?), fontforge(폰트편집기), mongodb, docker, psql? ...</div>
    <br>
    <div class="center" markdown>[<del>혹시 geek 한 감성이 충만하다면 이 페이지를 markdown 으로 보실래요?</del>](https://github.com/qwreey75/qwreey75.github.io/blob/master/src/introduce.md "➡ 히히 이동")</div>

## ❕ &nbsp;그래서 지금까지 한거좀 보여주시죠?

### 🔡 &nbsp;내눈에 이쁜 폰트가 없다면 직접 만들자! Kawaii Mono 제작기

<div class="center" markdown>
![KawaiiMono Font Preview](/image/introduce/kawaiiMono.png "좋은 가독성!")
</div>

거의 2달째 만들고 있는 폰트! [KawaiiMono (깃허브)](https://github.com/qwreey75/KawaiiMono) [(미러1)](https://git.pikokr.dev/Qwreey/KawaiiMono)  
글자마다 여러사람의 눈을 거치고, 한글 글리프는 나눔스퀘어 네오라는 이쁜 폰트에서 가져왔습니다  
아직 베타이지만 언젠간 완성할거니 많관부... 갠디하면 테스트용 ttf 파일 드려요  

??? note "만든 이유... 랄까"
    <br>
    둥글고 귀여운, 하지만 고정폭으로 코딩하기에 보기 좋은 폰트중 한국어가 지원되면서 nerd-fonts 글리프, 합자까지 있는게 거의 없다시피 했습니다.  
    아주아주 귀찮았지만 InputMono 라는 괜찮은 폰트에 [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) 글리프를 넣고 한글 글자를 [본고딕](https://fonts.google.com/noto/specimen/Noto+Sans+KR "(링크) 노토산스라고도 불리죠")에서 따오고 liga 글리프까지 넣어서 쓰고 있었지만 문제가 있었습니다  
    <br>
    <div class="center"><span style="font-size:1.2em">InputMono 가 사유 라이선스야!!</span>공유를 못한다고 ㅠㅠㅠㅠㅠ</div>

### 🔨 &nbsp;80 서버를 가진 작은봇 '미나'

<div class="center" markdown>
![KawaiiMono Font Preview](/image/introduce/mina.png "뭐라는거야 아니 호감도는 또 왜저래ㅋㅋㅋ")
</div>

80 서버를 가진 [디스코드봇 미나](https://github.com/qwreey75/MINA_DiscordBot "➡ 깃허브 저장소로 이동하기"). <del>작지만 엄청나게 갈려나간</del> [한디리에서 볼 수 있습니다](https://koreanbots.dev/bots/828894481289969665)  
음악 기능부터 <del>버그투성이</del> 가르치기 등 여러가지 명령어가 있습니다 <del>시간이 지나며 고장난게 많지만</del>  
<br>
작은 호스팅에서 시작한 특성상 성능에 올인한 개발이라는 특징을 가지고 있습니다  
가벼워서 지금 쓰는 서버에 그냥 얹어놓고 돌리는중  

??? note "더많은 정보"
    === "Trivia"
        <br>
        높은 성능을 위해 다이나믹 언어 구현체중 가장 빠른 luajit 를 차용했고, pthread 를 이용한 멀티스레딩, libuv 를 이용한 논블럭 io 로 기본 성능을 높이고, subprocess(childprocess) 로 음악 기능에서 미디어 처리를 분산했습니다.  
        고성능을 위해서 promise 나 mutex 같은 일반적인 라이브러리도 직접 작성했으며 2.6GHz*4 ARM 인스턴스 기준 음악 8서버에서 돌릴 때 CPU 사용율이 0.4% ~ 1% 내로 나옵니다 이전에 사용한 호스팅 (1.8GHz 였던걸로 기억) 에서도 2% 내였습니다  
        사용된 언어는 Lua, Python, C. 지금은 개발 구조가 개판나서 더이상 개발을 유지하고 있지는 않습니다. 1448 커밋에서 멈춰있는중  
        <br>다시만들기는 싫은게 자꾸 디스코드가 뭔가 추가하면서 만들꺼가 많아지더라고요. 버튼이랑 슬래시 커맨드 그리고 안정화를 하기 위해서 [라이브러리까지 다 뜯어고쳤는데](https://github.com/qwreey75/discordiaEnchant "(링크) ㅁㅣ친 라이브러리 discordia") 다시 그러고 싶지는 않음 ㅋㅋㅋㅋㅋㅋㅋ  
        제발 그냥 node js 와 ts 를 씁시다  
        <br>
        <div class="center" markdown>
        ![프로파일링 결과](/image/introduce/minaProfiler.png "좋은 가독성!")
        </div>
        <div class="center" style="font-size:1.06em">모든 서브프로세스와 서브스레드 로드에 300ms 면 충분...</div>
    === "자체 개발 라이브러리"
        <br>
        [로그를 이쁘게 logger.lua](https://github.com/qwreey75/logger.lua "(링크) 로그는 이쁘면 그만이야")  
        [약속과 반환 promise.lua](https://github.com/qwreey75/promise.lua "(링크) 노드js 의 promise 와 비슷하면서도, 오류처리가 강력합니다")  
        [뭐가 잘못된걸까? tester.lua](https://github.com/qwreey75/tester.lua "(링크) 근데 만들어놓고 잘 안씀")  
        [난 XML 이 싫어 myXml.lua](https://github.com/qwreey75/myXml.lua "(링크) 그러니 json 을 쓰자")  
        [뭐가 느린지 궁금하다 profiler.lua](https://github.com/qwreey75/profiler.lua "(링크) 이걸로 느린부분 찾아 고쳤더니 2초걸리는 셋업타임 0.3초됨")  
        [정밀한 랜덤이 필요해 random.lua](https://github.com/qwreey75/random.lua "(링크) 이상한 비트시프트 지옥")  
        [더많은 스레드!! worker.lua](https://github.com/qwreey75/worker.lua "(링크) 컴퓨터야 일하자")  
        [코드에도 교통정리가 필요해 mutex.lua](https://github.com/qwreey75/mutex.lua "(링크) 순서대로 일하자")  

### 🌟 200 스타를 넘은 무언가. quick-settings-tweaks

<div class="center" markdown>
![적용샷](/image/introduce/quickSettingsTweaks.png "시스템 메뉴에 여러가지 기능 추가해주는 gnome 플긴")
</div>
<br>
[<div class="center" markdown style="font-size:1.2em">
200 스타의 그 깃허브 저장소
</div>](https://github.com/qwreey75/quick-settings-tweaks "수준 미쳤다 ㄷㄷ")  
리눅스를 메인 데스크탑에 쓰면서 데스크탑 환경을 Gnome43 을 쓰고 있었습니다.  
그런데 프로그램별 소리조정도 없고 알림이랑 음악 정보는 딴곳에 떠서 통합된 느낌도, 편리한 느낌도 없었어서 그냥 직접 추가했습니다(?이게맞음?)  
내가 손댄적도 없는데 누가 AUR(아치리눅스 유저 레포) 에도 올려놨더라고요 ㅋㅋㅋㅋㅋ 아니 나혼자 쓸려 했던거 올린게 인기가 생길줄은 나도 몰랐음... <del>안올린 플러그인도 좀 있는데 올리면 어떻게될까요</del>  

### 🔨 &nbsp;디스코드와 마인크래프트를 연결하자! 플러그인도 없이!



### 학교활동

마크서버, 2019년 rblx 플러그인, 