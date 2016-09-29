import Player from "./player"

let Video = {
  init(socket, elemId, videoId, playerId) { if (!elemId) { return }
    socket.connect();
    Player.init(elemId, playerId, () => {
      this.onReady(videoId, socket)
    })
  },

  onReady(videoId, socket) {
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    //let vidChannel = socket.channel("videos:" + videoId)

    postButton.addEventListener("click", e => {
      /*
      let payload = {body: msgInput.value, at: Player.getCurrentTime()}
      vidChannel.push("new_annot", payload)
                .receive("error", e => console.log("[ERROR]", e))
      */
      this.renderAnnotation(msgContainer, {body: msgInput.value, user:{username: "charlie"}})
      msgInput.value = ""
    })

    /*
    vidChannel.on("new_annot", resp => {
      vidChannel.params.last_seen_annot_id = resp.id
      this.renderAnnotation(msgContainer, resp)
    })


    msgContainer.addEventListener("click", e => {
      e.preventDefault()
      let seconds = e.target.getAttribute("data-seek") ||
                    e.target.parentNode.getAttribute("data-seek")
      if (!seconds) { return }
      Player.seekTo(seconds)
    })

    vidChannel.join()
      .receive("ok", resp => {
        let annotIds = resp.annotations.map(annot => annot.id)
        if (annotIds.length > 0) {
          vidChannel.params.last_seen_annot_id = Math.max(...annotIds)
        }
        console.log("joined video chan", resp)
        this.scheduleMessages(msgContainer, resp.annotations)
      })
      .receive("error", err => console.log("failed to join video chan", err))
    */
  },

  esc(str) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML;
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    let template = document.createElement("div")
    template.innerHTML = `
    <a href="#" data-seek="${''/*this.esc(at)*/}">
      [${''/*this.formatTime(at)*/}]
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `
    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },

  scheduleMessages(msgContainer, annotations) {
    setTimeout(() => {
      let ctime = Player.getCurrentTime()
      let remaining = this.renderAtTime(annotations, ctime, msgContainer)
      this.scheduleMessages(msgContainer, remaining)
    }, 1000)
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter( annot => {
      if (annot.at > seconds) {
        return true
      } else {
        this.renderAnnotation(msgContainer, annot)
        return false
      }
    })
  },

  formatTime(at) {
    let date = new Date(null)
    date.setSeconds(at/1000)
    return date.toISOString().substr(14, 5)
  }

}
export default Video
