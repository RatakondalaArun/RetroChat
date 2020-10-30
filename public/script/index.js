const body = document.getElementsByName("body");
const app = document.getElementById("app");
let ws = null;
const user = {
  id: null,
  name: null,
  room: null,
  isValid() {
    return this.id != null && this.name != null && this.room != null;
  },
  saveUserData() {
    localStorage.setItem("id", this.id);
    localStorage.setItem("name", this.name);
    localStorage.setItem("room", this.room);
  },
  loadUserData() {
    this.id = localStorage.getItem("id");
    this.name = localStorage.getItem("name");
    this.room = localStorage.getItem("room");
    console.log(this.id, this.name, this.room);
  },
  delete() {
    localStorage.removeItem("id");
    localStorage.removeItem("name");
    localStorage.removeItem("room");
  },
};

function loadComponents() {
  user.loadUserData();
  console.log("is not valid", !user.isValid());
  if (!user.isValid()) {
    user.name = prompt("Your name");
    user.room = prompt("Room name");
    user.saveUserData();
  }
  loadWebSocketComponents();
  document.getElementById("user-name").textContent = `Logged In as (${user.name})`;
  document.getElementById("user-room").textContent = `Room: (${user.room})`;
  document.getElementById("reset-btn").onclick = () => {
    user.delete();
    closeWebSocket();
    loadComponents();
  };
}

function loadWebSocketComponents() {
  ws = new WebSocket(`ws://localhost:8080/ws?user=${user.name}&room=${user.room}`);
  ws.onopen = (event) => {
    console.log("Socket Opened: ", event);
    document.getElementById("connection-status").classList.toggle("online");
  };
  ws.onmessage = handleMessageFromServer;

  ws.onclose = (event) => {
    closeWebSocket();
  };
  ws.onerror = (err) => console.log("WebSocket Error: ", err);
  document.getElementById("send-btn").onclick = sendMessage;
  document.getElementById("message-box").onkeydown = (event) => {
    if (event.key == "Enter") sendMessage();
  };
}

function closeWebSocket() {
  ws.close();
  ws = null;
  // TODO: rename id to connection status
  document.getElementById("connection-status").classList.toggle("online");
}

function handleMessageFromServer(payload) {
  const message = JSON.parse(payload.data);
  if (message.type === "first") {
    user.id = message.clientId;
    console.log("user", user);
    user.saveUserData();
    return;
  }
  console.log("message clientId == user.id ", message.clientId === user.id);
  console.log("clientid : ", message.clientId);
  console.log("userid : ", user.id);
  const node = document.createElement("p");
  node.classList.add("chat", message.clientId === user.id ? "sent-chat" : "received-chat");
  const date = new Date(Date.parse(message.timestamp));
  node.innerText = `[${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}] [${
    message.clientName
  }]>> ${message.message}`;
  document.getElementById("output-screen").appendChild(node);
  document.getElementById("output-screen").scrollBy(0, 100);
}

function sendMessage() {
  if (document.getElementById("message-box").value === "") return;
  if (ws === null) loadWebSocketComponents();
  ws.send(
    JSON.stringify({
      id: uuid.v1(),
      clientId: user.id,
      name: user.name,
      message: document.getElementById("message-box").value,
    })
  );
  document.getElementById("message-box").value = "";
}

window.onload = loadComponents;
// TODO: clear local settings
// window.onclose = () => user.delete();
