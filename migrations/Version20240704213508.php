<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20240704213508 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // Table admin
        $this->addSql('CREATE TABLE admin (
        id SERIAL NOT NULL,
        username VARCHAR(180) NOT NULL,
        roles JSONB NOT NULL,
        password VARCHAR(255) NOT NULL,
        PRIMARY KEY(id),
        CONSTRAINT uniq_admin_username UNIQUE (username)
    )');

        // Table author
        $this->addSql('CREATE TABLE author (
        id SERIAL NOT NULL,
        name VARCHAR(255) NOT NULL,
        PRIMARY KEY(id)
    )');

        // Table joke
        $this->addSql('CREATE TABLE joke (
        id SERIAL NOT NULL,
        author_id INT NOT NULL,
        content TEXT NOT NULL,
        answer VARCHAR(255) NOT NULL,
        PRIMARY KEY(id),
        CONSTRAINT fk_joke_author FOREIGN KEY (author_id) REFERENCES author (id) NOT DEFERRABLE INITIALLY IMMEDIATE
    )');

        // Index sur author_id
        $this->addSql('CREATE INDEX idx_joke_author_id ON joke (author_id)');
    }

    public function down(Schema $schema): void
    {
        // Supprimer d’abord les tables dépendantes à cause des FK
        $this->addSql('DROP TABLE IF EXISTS joke CASCADE');
        $this->addSql('DROP TABLE IF EXISTS admin CASCADE');
        $this->addSql('DROP TABLE IF EXISTS author CASCADE');
    }
}
