import React from "react";

const mock = [
  { id: 1, name: "Sunrise Mansion 101", city: "Hitachi", price: 58000 },
  { id: 2, name: "Seaside Heights A-3", city: "Kitaibaraki", price: 72000 },
];

export default function Properties() {
  return (
    <section>
      <h1>Properties</h1>
      <ul style={{ paddingLeft: "1rem" }}>
        {mock.map(p => (
          <li key={p.id} style={{ margin: ".5rem 0" }}>
            <strong>{p.name}</strong> — {p.city} / ¥{p.price.toLocaleString()}
          </li>
        ))}
      </ul>
    </section>
  );
}
