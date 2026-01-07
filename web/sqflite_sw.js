// sqflite_sw.js - Service Worker for sqflite web
// Based on sqflite_common_ffi_web

importScripts('https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.10.3/sql-wasm.js');

let db = null;
let SQL = null;

async function initSqlJs() {
  if (!SQL) {
    SQL = await initSqlJs({
      locateFile: file => `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.10.3/${file}`
    });
  }
  return SQL;
}

self.onmessage = async function(e) {
  const { id, action, args } = e.data;
  
  try {
    let result;
    
    switch (action) {
      case 'open':
        await initSqlJs();
        db = new SQL.Database();
        result = true;
        break;
        
      case 'execute':
        if (!db) throw new Error('Database not opened');
        db.run(args.sql, args.params);
        result = { changes: db.getRowsModified() };
        break;
        
      case 'query':
        if (!db) throw new Error('Database not opened');
        const stmt = db.prepare(args.sql);
        stmt.bind(args.params);
        const rows = [];
        while (stmt.step()) {
          rows.push(stmt.getAsObject());
        }
        stmt.free();
        result = rows;
        break;
        
      case 'close':
        if (db) {
          db.close();
          db = null;
        }
        result = true;
        break;
        
      default:
        throw new Error(`Unknown action: ${action}`);
    }
    
    self.postMessage({ id, result });
  } catch (error) {
    self.postMessage({ id, error: error.message });
  }
};