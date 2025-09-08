<?php

namespace App\DataFixtures;

use App\Entity\Admin;
use App\Entity\Author;
use App\Entity\Joke;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

// 
class JokesAppFixtures extends Fixture
{
    private $passwordHasher;

    public function __construct(UserPasswordHasherInterface $passwordHasher)
    {
        $this->passwordHasher = $passwordHasher;
    }

    public function load(ObjectManager $manager)
    {
        // ----- Admin -----
        $admin = new Admin();
        $admin->setUsername('admin');
        $admin->setRoles(['ROLE_ADMIN']);
        $admin->setPassword($this->passwordHasher->hashPassword($admin, getenv('ADMIN_PASSWORD')));
        $manager->persist($admin);

        // ----- Auteurs -----
        $authors = [
            'Coluche' => [
                ["Pourquoi les politiciens ne jouent jamais à cache-cache ?", "Parce qu’ils ne veulent jamais être trouvés !"],
                ["Que fait un chômeur qui gagne au loto ?", "Il retourne travailler, juste pour s’ennuyer."],
                ["Pourquoi les poules traversent-elles la route ?", "Pour échapper aux carnivores !"],
                ["Comment appelle-t-on un fonctionnaire joyeux ?", "Un mythe."],
                ["Pourquoi boire du vin ?", "Parce que l’eau ça mouille."],
                ["Pourquoi l’alcool tue lentement ?", "Parce qu’on n’est pas pressés !"],
                ["Que dit un riche en voyant un pauvre ?", "Bonjour, je vous salue… de loin."],
                ["Pourquoi la maison de retraite est tranquille ?", "Parce que les habitants dorment beaucoup."],
                ["Que fait un politicien le dimanche ?", "Il se repose sur ses promesses."],
                ["Pourquoi Dieu a créé l’homme avant la femme ?", "Parce qu’il fallait un brouillon."]
            ],
            'Raymond Devos' => [
                ["Pourquoi j’ai mis ma montre à l’heure ?", "Mais elle n’a pas voulu !"],
                ["Pourquoi le train m’a laissé tomber ?", "Parce qu’il allait trop vite."],
                ["Que fait un fou qui marche ?", "Il va plus loin que deux intellectuels assis."],
                ["Pourquoi le rire est sérieux ?", "Parce qu’on ne doit pas plaisanter avec."],
                ["Pourquoi mettre un parachute ?", "Quand on n’a pas d’intelligence, on s’écrase."],
                ["Pourquoi l’éternité est longue ?", "Surtout vers la fin."],
                ["Que dit un optimiste expérimenté ?", "Je suis pessimiste."],
                ["Pourquoi s’exprimer mal ?", "Pour être compris… justement !"],
                ["Pourquoi courir après son ombre ?", "Elle court plus vite que nous."],
                ["Pourquoi le temps c’est de l’argent ?", "Parce qu’on en manque toujours."]
            ],
            'Pierre Desproges' => [
                ["On peut rire de tout ?", "Oui, mais pas avec tout le monde."],
                ["Pourquoi l’intelligence est comme un parachute ?", "Quand on n’en a pas, on s’écrase."],
                ["Que vaut mieux faire ?", "Rire des choses tristes plutôt que pleurer sur des choses drôles."],
                ["La culture est comme quoi ?", "Comme la confiture : moins on en a, plus on l’étale."],
                ["Que fait Dieu ?", "Les riches ont la nourriture, les pauvres l’appétit."],
                ["Que ferait la gauche si elle savait ?", "Ça se saurait."],
                ["C’est quoi l’amour ?", "Recevoir une gifle et tendre l’autre joue pour un bisou."],
                ["Le pessimiste est ?", "Un optimiste qui a de l’expérience."],
                ["Le rire sert à ?", "Désarmer plus sûrement que la haine."],
                ["Les statistiques sont ?", "Comme les bikinis : ça cache l’essentiel."]
            ],
            'Toto' => [
                ["Pourquoi Toto met-il son cahier au frigo ?", "Pour avoir des devoirs frais !"],
                ["Toto dit à la maîtresse : « Je ne veux pas faire mes devoirs ».", "La maîtresse répond : « Alors, tu iras en retenue ! »"],
                ["Pourquoi Toto a mis son ordinateur dans le four ?", "Pour cuire des cookies."],
                ["Toto demande : « Madame, je peux aller aux toilettes ? »", "La maîtresse répond : « Oui, mais pas pendant la récré ! »"],
                ["Pourquoi Toto a pris un échelle pour l’école ?", "Parce qu’il voulait aller en classe supérieure."],
                ["Toto a mis son réveil à l’envers…", "Pour arriver en retard à l’heure !"],
                ["Toto et le ballon…", "Il a cru qu’il fallait l’envoyer dans le ballon du voisin."],
                ["Pourquoi Toto n’a pas mangé sa soupe ?", "Parce qu’il préférait la manger avec les doigts."],
                ["Toto dit : « Mon chien parle »", "Ses parents disent : « C’est toi qui parles tout seul ! »"],
                ["Pourquoi Toto a mis son vélo dans le frigo ?", "Pour pédaler au frais."]
            ],
            'Muriel Robin' => [
                ["Pourquoi les femmes se maquillent ?", "Pour que les hommes les reconnaissent."],
                ["Que fait une comédienne dans sa cuisine ?", "Elle joue avec les casseroles."],
                ["Pourquoi Muriel adore le café ?", "Parce que ça lui donne de l’humour."],
                ["Pourquoi les escaliers ne se plaignent jamais ?", "Parce qu’ils montent et descendent sans broncher."],
                ["Comment appelle-t-on une actrice qui se perd ?", "Une star en errance."],
                ["Pourquoi les chaussures font-elles mal ?", "Parce qu’elles veulent qu’on marche droit."],
                ["Pourquoi rire est important ?", "Parce que ça muscle le visage."],
                ["Pourquoi les chats aiment les planches à repasser ?", "Parce qu’ils sont pressés."],
                ["Que dit une actrice fatiguée ?", "J’ai besoin de standing ovation pour dormir."],
                ["Pourquoi Muriel adore les fêtes ?", "Parce que c’est là qu’on rit le plus."]
            ],
            'Gad Elmaleh' => [
                ["Pourquoi les enfants adorent l’école ?", "Parce que c’est là qu’on rigole le plus."],
                ["Que fait un humoriste sur scène ?", "Il observe les réactions du public."],
                ["Pourquoi Gad aime les animaux ?", "Parce qu’ils n’ont pas de portable."],
                ["Comment appelle-t-on un sketch raté ?", "Un apprentissage comique."],
                ["Pourquoi les vacances sont courtes ?", "Pour mieux les apprécier."],
                ["Que fait Gad quand il est en retard ?", "Il improvise l’entrée en scène."],
                ["Pourquoi les spectacles drôles attirent du monde ?", "Parce que tout le monde veut sourire."],
                ["Que dit un comédien stressé ?", "Je préfère les applaudissements aux larmes."],
                ["Pourquoi Gad utilise des accents ?", "Pour que chaque mot ait sa saveur."],
                ["Comment finir un spectacle ?", "Par un grand éclat de rire."]
            ]
        ];

        foreach ($authors as $authorName => $jokes) {
            $author = new Author();
            $author->setName($authorName);

            foreach ($jokes as [$question, $answer]) {
                $joke = new Joke();
                $joke->setContent($question);
                $joke->setAnswer($answer);
                $joke->setAuthor($author);
                $manager->persist($joke);
            }

            $manager->persist($author);
        }

        $manager->flush();
    }
}
