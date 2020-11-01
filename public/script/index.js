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
    this.name = window.url("?username") ?? localStorage.getItem("name");
    this.room = window.url("?room") ?? localStorage.getItem("room");
  },
  delete() {
    localStorage.removeItem("id");
    localStorage.removeItem("name");
    localStorage.removeItem("room");
  },
};

function loadComponents() {
  user.loadUserData();

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
  document.getElementById("share-btn").onclick = async () => {
    console.log(`https://${location.host}?room=${user.room}`);
    const url = `${isLocalHost() ? "" : "https://"}${location.host}?room=${user.room}`;
    await navigator.clipboard.writeText(url);
    document.getElementById("share-btn").value = "Copied!";
    setTimeout(() => (document.getElementById("share-btn").value = "Share"), 2000);
  };
}

function loadWebSocketComponents() {
  const protocal = isLocalHost() ? "ws" : "wss";
  ws = new WebSocket(`${protocal}://${location.host}/ws?user=${user.name}&room=${user.room}`);
  ws.onopen = (_) => {
    document.getElementById("connection-status").classList.toggle("online");
  };
  ws.onmessage = handleMessageFromServer;

  ws.onclose = (_) => {
    closeWebSocket();
  };
  ws.onerror = (_) => (document.getElementById("send-btn").onclick = sendMessage);
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
  // TODO: rename to pong
  if (message.type === "first") {
    user.id = message.clientId;
    user.saveUserData();
    return;
  }

  const node = document.createElement("p");
  node.classList.add("chat", message.clientId === user.id ? "sent-chat" : "received-chat");
  const date = new Date(Date.parse(message.timestamp));
  node.innerText = `[${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}][${
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
      clientId: user.id,
      name: user.name,
      message: document.getElementById("message-box").value,
    })
  );
  document.getElementById("message-box").value = "";
}

function isLocalHost() {
  return location.host.includes("localhost") || location.host.includes("127.0.0.1");
}

window.onload = loadComponents;
