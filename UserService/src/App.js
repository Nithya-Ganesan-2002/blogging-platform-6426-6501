import React from 'react';
import fixtures from './mock/fixtures.json';
export default function App(){ return React.createElement('div',null, 'UserService mock count: '+(fixtures.users||[]).length); }
